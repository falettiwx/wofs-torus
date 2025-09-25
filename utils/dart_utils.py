import numpy as np
import sys, os, glob
import datetime as dtime
import xarray as xr
import netCDF4 as ncdf
import time as timeit
from scipy.spatial import KDTree
from pyproj import Transformer

try:
    import _pickle as pickle
except:
    import pickle

debug = True

__missing = -9999.
__gravity = 9.806

#-------------------------------------------------------------------------------
# WRF File variable dictionary

wrf_var_dict = { 'u': 'U', 'v': 'V', 'w': 'W', 'pb': 'P_HYD', 'pp': 'P', 
                'ph': 'ph', 'phb': 'phb', 'th': 'T', 'qv': 'QV', 
              'refl': 'REF_10CM', 'lat': 'XLAT', 'lon': 'XLONG' } 

#-------------------------------------------------------------------------------
# MPAS File variable dictionary

mpas_var_dict = { 'w': 'w', 'z': 'zgrid', 'th': 'theta', 'qv': 'qv', 
                 'pb': 'pressure_base', 'pp': 'pressure_p', 
                'refl': 'ref10cm', 'lat': 'latcell', 'lon': 'loncell' } 

#-------------------------------------------------------------------------------
#
def read_model_grid(model_file, model_type='wrf', write_new_file=True): 

    #-------------------------------------------------------------------------------
    # ===> BEGIN: MODEL FIELDS and CREATE LOCATION ARRAYS

    if model_type == 'mpas':
    
        ds = read_netcdf(model_file, retFileAttr = False)
    
        nz    = ds.dims['nVertLevels']
        nCell = ds.dims['nCells']
    
        latCell     = np.rad2deg(np.squeeze(ds['latCell'].values))
        lonCell     = np.rad2deg(np.squeeze(ds['lonCell'].values))
        zgrid       = np.squeeze(ds['zgrid'].values)
        mod_refl    = np.squeeze(ds['refl10cm'].values).flatten()
        bdyMaskCell = ds['bdyMaskCell'].values
    
        # create zone-centered vertical grid values and flatten array
    
        hgt3D = (0.5*(zgrid[:,1:] + zgrid[:,:-1])).flatten()
    
        # make sure that lons are between 0 and 360 degress
    
        lonCell = np.where( lonCell < 0.0,   lonCell+360., lonCell)
        lonCell = np.where( lonCell > 360.0, lonCell-360., lonCell)
    
        # map model lat/lon into physical distance in meters
    
        model_transformer = mapping_transform(latCell.mean(), lonCell.mean())
    
        xCell, yCell = model_transformer.transform(lonCell, latCell)
        
        # close mpas file
    
        ds.close()

        nx = nCell
        ny = 0
    
    else: # wrf model
    
        ds, attrib = read_netcdf(model_file, retFileAttr = True)
    
        nz = ds.dims['bottom_top']
        nx = ds.dims['west_east']
        ny = ds.dims['south_north']
    
        latCell  = np.squeeze(ds['XLAT'].values).transpose().flatten()
        lonCell  = np.squeeze(ds['XLONG'].values).transpose().flatten()
        phb      = np.squeeze(ds['PHB'].values)
        mod_refl = np.squeeze(ds['REFL_10CM'].values).transpose().flatten()
    
        # create zone-centered vertical grid locations
        
        hgt3D = (0.5*(phb[1:] + phb[:-1]) / __gravity).transpose().flatten()
    
        if debug:  print('\n WRF MODEL GRID: NZ = %d  NY = %d  NX = %d' % (phb.shape[:]))
        
        # make sure that lons are between 0 and 360 degress
    
        lonCell = np.where( lonCell < 0.0,   lonCell+360., lonCell)
        lonCell = np.where( lonCell > 360.0, lonCell-360., lonCell)
    
        # map model lat/lon into physical distance in meters
        
        model_transformer = mapping_transform(attrib['CEN_LAT'], attrib['CEN_LON'], debug=False)
    
        xCell, yCell = model_transformer.transform(lonCell, latCell)
    
    
        # close wrf file
    
        ds.close()

    xCell3D = np.dstack([xCell]*nz).flatten()
    yCell3D = np.dstack([yCell]*nz).flatten()

    return xCell3D, yCell3D, hgt3D, model_transformer, latCell, lonCell, nx, ny, nz

#-------------------------------------------------------------------------------
#
def write_model_grid(model_file, noise, sd, model_type='wrf', write_new_file=True):

    ts0      = 300.
    ps0      = 1.0e5
    Cp       = 1004.
    Cv       = 787.
    Rd       = 257.
    Rv       = 461.
    kappa    = 2.0 / 7.0
    t_kelvin = 273.16   
    rd_o_rv  = Rd / Rv
    cp_o_cv  = Cp / Cv

    #-------------------------------------------------------------------------------
    def compute_td(p, qv):
        e = qv * p / (0.622 + qv)                                        # vapor pressure
        e = np.where(e > 0.001, e, 0.001)                                # avoid problems near zero
        return t_kelvin + (243.5 / ((17.67 / np.log(e/6.112)) - 1.0) )      # Bolton's approximation

    #-------------------------------------------------------------------------------
    def compute_qv(p, td):
        tdc = td - t_kelvin
        e = 6.112 * np.exp( 17.67 * tdc / (tdc + 243.5) )       # Bolton's approximation
        return (0.622 * e / (p-e))

    nflds = sd.size
    print(" NFLDS: ", nflds)

    #-------------------------------------------------------------------------------
    # ===> BEGIN: MODEL FIELDS and CREATE LOCATION ARRAYS

    if model_type == 'mpas':

        mpas_vars = ['U', 'V', 'W', 'T', 'TD', 'QV']

        ds = ncdf.Dataset(model_file, 'r+')

        nz    = ds.dimensions['nVertLevels'].size
        nCell = ds.dimensions['nCells'].size

        noise = noise.reshape(nCell, nz, nflds)
        
        for n, var in enumerate(mpas_vars):

            if np.abs(sd[n]) > 0.0:

                if var == 'u':
                    pass
    
                elif var == 'v':
                    pass
    
                elif var == 'w':
                    ds.variables[var][0, :, 1:-1] += 0.5*(noise[:,1:,n] + noise[:,:-1,n])
    
                elif var == 'td':  # lots of work here....
                    th   = np.squeeze(ds.variables['theta'][...])
                    qv   = np.squeeze(ds.variables['qv'][...])
                    pres = 0.01 * (np.squeeze(ds.variables['pressure_base'][...]))
                    temp = th * np.squeeze(ds.variables['exner'][...])

                    td   = compute_td(pres, qv)
                    td  += noise[:,:,n]
                    td   = np.where(temp+4.0 > td, td, temp+4.0)  # limit td supersaturation to T+4 deg.
                    
                    ds.variables['qv'][0] += (compute_qv(pres, td) - qv)
    
                else:
                    ds.variables[var][0] += noise[:,:,n]
    
                if debug:  print(" Added noise to %s " % var)
                
            else:
            
                if debug:  print(" Did NOT ADD noise to %s " % var)

        ds.close()

    else:

        wrf_vars = ['U', 'V', 'W', 'T', 'TD', 'QV']

        ds = ncdf.Dataset(model_file, 'r+')

        nz = ds.dimensions['bottom_top'].size
        nx = ds.dimensions['west_east'].size
        ny = ds.dimensions['south_north'].size

        noise = noise.reshape(nx, ny, nz, nflds).transpose()

        for n, var in enumerate(wrf_vars):

            if np.abs(sd[n]) > 0.0:

                if var == 'U':
                    ds.variables[var][0, :, :, 1:-1] += 0.5*(noise[n,:,:,1:] + noise[n,:,:,:-1])

                elif var == 'V':
                    ds.variables[var][0, :, 1:-1, :] += 0.5*(noise[n,:,1:,:] + noise[n,:,:-1,:])

                elif var == 'W':
                    ds.variables[var][0, 1:-1, :, :] += 0.5*(noise[n,1:,:,:] + noise[n,:-1,:,:])

                elif var == 'TD':  # lots of work here....
                    th   = np.squeeze(ds.variables['T'][...]) + ts0
                    qv   = np.squeeze(ds.variables['QVAPOR'][...])
                    pres = 0.01 * np.squeeze(ds.variables['P_HYD'][...])
                    temp = (ts0 + th) * (100.0*pres/ps0)**kappa

                    td   = compute_td(pres, qv)
                    td  += noise[n]

                    td   = np.where(temp+4.0 > td, td, temp+4.0)  # limit td supersaturation to T+4 deg.
                      
                    ds.variables['QVAPOR'][0] += (compute_qv(pres, td) - qv)

                else:
                    ds.variables[var][0] += noise[n]

                if debug:  print(" Added noise to %s " % var)
                    
            else:
            
                if debug:  print(" Did NOT ADD noise to %s " % var)
 
        # close wrf file

        ds.close()

    return 

#-------------------------------------------------------------------------------
#
def mapping_transform(meanlat, meanlon, debug=False):
    
    # map projection for converting lat,lon to meters

    proj_daymet = "+proj=lcc +lat_0=%f +lon_0=%f +lat_1=30 +lat_2=60 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs" \
                % (meanlat, meanlon)
    
    if debug:  print("\n String passed to map projection: "+proj_daymet+"\n")
    return  Transformer.from_crs("EPSG:4326", proj_daymet, always_xy=True)

#-------------------------------------------------------------------------------
#
def read_netcdf(filename, retFileAttr = False, debug=False):
    if retFileAttr == False:
        return xr.open_dataset(filename, decode_times=False)
    else:
        xa = xr.open_dataset(filename, decode_times=False)
        return xa, xa.attrs

#-------------------------------------------------------------------------------
#
def obs_seq_get_obtype(ds, list_obs_types=False, kind=None, name=None, refl_thresh=None, debug=False):
    
    """ obs_seq_get_obtype reads observations from the obs_seq netCDF4 file created
        during cycling data assimilation
    """
    
    routine_name = 'obs_seq_get_obtype'.upper()
    print('\n ------------------ %s has been called -----------------------\n' % routine_name)
    

    if list_obs_types:
        list_set = set(ds['obs_type'].values.tolist())
        unique_list = (list(list_set))

        for item in unique_list:
            idx = ds['ObsTypes'].to_numpy()[item]
            print(" OBS TYPE INDEX: %3.3d  OBS_TYPE: %s" % (idx, ds['ObsTypesMetaData'].values[item].decode()))
         
        return None

    if name:
        idx  = np.where(ds['ObsTypesMetaData'].values == name)[0][0] 
        kind = ds['ObsTypes'].to_numpy()[idx]
        meta = ds['ObsTypesMetaData'].values[np.where(ds['ObsTypesMetaData'].str.find(name) == 0)[0][0]]

    if kind == None:
        print(" OBS_SEQ_GET_OBTYPE:  no kind or name specified, exiting \n")
        sys.exit(-1)
        
    else:      
        
        index_type = np.where(ds['obs_type'].values == kind)
        
        print(" FOUND %d OBS FOR VARIABLE: %s\n" % (np.sum(ds['obs_type'].values == kind), meta.decode()))
   
        if refl_thresh != None:
                
            refl = ds['observations'].values[index_type]
            index_thresh = np.where(refl[:,0] >= refl_thresh)
            
            print(" FOUND %d OBS FOR REFL_THRES >=  %f for VARIABLE: %s\n" % (len(index_thresh[0]), refl_thresh, meta.decode()))
            
            idx = index_thresh[0]
            
        else:
            idx = index_type[0]
                  
        
        if len(idx) > 0:

            return {'obs':        ds['observations'].values[idx],
                    'location':   ds['location'].values[idx],
                    'qc':         ds['location'].values[idx],
                    'which_vert': ds['location'].values[idx],
                    'time':       ds['time'].values[idx]}
        else:
            return {'obs':        None,
                    'location':   None,
                    'qc':         None,
                    'which_vert': None,
                    'time':       None}
    
#-------------------------------------------------------------------------------
#
def obs_seq_get_CopyMetaDataIndex(ds, meta_name=None, list=False, all=False, debug=False):
    
    if list:
        print(ds['CopyMetaData'])
        
    if all:
        return ds['CopyMetaData']
    
    else:
        metalist  = ds['CopyMetaData'].values.tolist()
        ret_index = []

        for n, item in enumerate(metalist):
            try:
                if meta_name.index(item) >= 0:
                    ret_index.append(n)
            except:
                pass
        return ret_index
