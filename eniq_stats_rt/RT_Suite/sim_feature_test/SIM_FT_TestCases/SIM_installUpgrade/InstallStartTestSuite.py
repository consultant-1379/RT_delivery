
'''
Created on Aug 27, 2015

@author: Calvin
'''


import subprocess
import os
import signal
import datetime
from time import sleep
from sys import stdout



class InstallStartTestSuite(object):
    
   
     
    def checkForWarningsErrorsSimInstallLog(self, simVersionUsed):
        
        'Clearing the log for start of tests'
        bpr = subprocess.Popen(['> /eniq/log/sw_log/sim/sim.log'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        bpr.communicate()
        
        simVersion = simVersionUsed.replace('-', '_')
        
        print 'Checking /eniq/log/sw_log/platform_installer/'+simVersion+'* for errors \n'
        
        
      
        bpr = subprocess.Popen(['cat /eniq/log/sw_log/platform_installer/'+simVersion+'*;'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        output = str(stdout_value) 
        
     
        
        if '(\'\', None)' in output:
            print 'Fail - Error opening file, test cannot execute'
            return False
        
        sentences = output.rstrip().split('\\n')
        
        
        for sentence in sentences:
            if "error" in sentence or "warning" in sentence:
                print 'Failed - Errors and/or warnings in log \n'
                return False
            
            
        print 'Passed - CheckForWarningsErrorsSimInstallLog \n'
        return True
    
    def dcuserSuccessStart(self, simVersion):
        
        print 'Attempting to start and stop SIM as dcuser \n'
       
        bpr = subprocess.Popen(['sim stop; sim start; sim status'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        status = str(stdout_value)
        sentence = status.rstrip().split('\\n')
        
        for s in sentence:
            if 'Running' in s:
                print 'Passed - dcuserSuccessStart'
                return True
        print 'Failed'
        return False
    
    
    
    def configFilesPresentAfterInstallation(self, simVersion):
       
        print 'Checking /eniq/sw/conf/sim for 3 .simc files \n'
    
        bpr = subprocess.Popen(['ls /eniq/sw/conf/sim'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        count = 0
        files = str(stdout_value)
        fileArray = files.rstrip().split('\\n')
        
        for fileMy in fileArray:
            if 'intervals.simc' in fileMy or 'properties.simc' in fileMy or 'protocols.simc' in fileMy:
                count += 1
        
        if count == 3:
            print 'Passed - ConfigFilesPresentAfterInstallation \n'
            return True
        print 'Failed - There should be 3 simc files (intervals, properties, protocols) \n'
        return False
    
    
    
    
    def verifyNonOperationOfSIMWithInvalidLicense(self, simVersion):
        
        print 'Verifying that SIM is not operational w/o a valid license \n'
        
        
        bpr = subprocess.Popen(['sim stop; licmgr -uninstall CXC4012008;sim start; sim status;'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        status = str(stdout_value)
        sentences = status.rstrip().split('\\n')
        
        pro = subprocess.Popen(['sim stop; licmgr -install /eniq/sw/platform/'+simVersion+'/sim_feature_test/ENIQ_S16A; sim start;'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        value = pro.communicate()
        
        
        for sentence in sentences:
            
            if  'No valid SIM license found. SIM is not operational' in sentence:
                print 'Passed - SIM not running due to invalid license \n'
                return True
        print 'Failed - SIM is operational without valid license \n'
        return False
    
    def verifyTopologyExportImport(self, simVersion):
       
        print 'Verifying the import and export of topology \n'
        
        
        resultExport = False
        resultImport = False
        
      
        bpr = subprocess.Popen(['sim config import /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/topologyTest.csv'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        info = str(stdout_value)
    
        lines = info.rstrip().split('\\n')
        
        if 'Imported: 7 Nodes' in lines[1] and 'Ignored: 1 Nodes' in lines[2]:
            resultImport = True
        else:
            print 'Failed Import - Check that the test matches both what is expected for import \n'
                
        
    
        
        bpr = subprocess.Popen(['sim config import /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/topology.csv; sim config export /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/export.csv; diff /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/topology.csv /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/export.csv > /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/diff.txt; du -sh /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/diff.txt; rm /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/diff.txt /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/export.csv ' ], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        out = str(stdout_value)

        
        if '0K' in out:
            resultExport = True
        else:
            print 'Failed export - Check that the expected export file matched the actual exported file \n'
        
        
        if resultImport == True and resultExport == True:
            print 'Passed - Import/Export of topology success \n'
            return True
        
        return False
       
    def verifyTopologyUpgrade(self, simVersion):
        
        print 'Verifying upgrade topology scenario \n'
        
        
        bpr = subprocess.Popen(['sim config import /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/upgrade.csv'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        info = str(stdout_value)
        lines = info.rstrip().split('\\n')
        
        if 'Imported: 6 Nodes' in lines[1] and 'Ignored: 2 Nodes' in lines[2]:
            print 'Passed - Upgraded topology scenario'
            return True
        print 'Failed - Check the number of nodes imported/ignored match what the test expects \n'    
        return False
        
       
   
    def xRootUserFail(self, simVersion):
  
        print 'Should fail attempting to start SIM \n'
     
        
        
        bpr = subprocess.Popen(['/eniq/sw/platform/'+simVersion+'/sim_feature_test/scripts/./rootUserLogIn.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_val = bpr.communicate()
        result = str(stdout_val)
       
        
        if 'usr/local/etc/sudoers.d is owned by uid 2, should be 0' in result:
            print 'Passed - Root user cannot start sim'
            return True
        print 'Failed - sim has been started by root user \n'
        return False
    
    
    def zLoadConfiguration(self, simVersion):
           
        print 'Loading the configuration for SIM file Collections for Feature Test \n'
        
        
        bpr = subprocess.Popen(['sim config import /eniq/sw/platform/'+simVersion+'/sim_feature_test/testFiles/topology.csv'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        
        stdout_value = bpr.communicate()
        info = str(stdout_value)
        lines = info.rstrip().split('\\n')
        
        bpr = subprocess.Popen(['sim stop'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        
        now = datetime.datetime.now()
        minute = now.minute
        
        'Renaming the file to todays current date so SIM will not ignore it'
        bpr = subprocess.Popen(['/eniq/sw/platform/'+simVersion+'/sim_feature_test/scripts/./renameAppendedFile.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        
        print 'Waiting until the next ROP is on the hour before starting SIM \n'
        while (minute >=0 and minute <=55) :
            
            sleep(45)
            now = datetime.datetime.now()
            minute = now.minute
         
        
        
        
        print 'Starting SIM \n'    
        bpr = subprocess.Popen(['sim start;'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        stdout_value = bpr.communicate()
        
        'Filling up the input directories with one file to test non-collection'
        
        
        
        bpr = subprocess.Popen(['/eniq/sw/platform/'+simVersion+'/sim_feature_test/scripts/./preFirstROP.sh'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        out=bpr.communicate()
      
  
        if 'Imported: 7 Nodes' in lines[1] and 'Ignored: 0 Nodes' in lines[2]:
            print 'Passed - Configuration file for reactive tests has been successfully applied \n'
            return True
        print 'Failed - Check the number of nodes imported/ignored match what the test expects \n'    
        return False
        
          
        
        
    
    
        
   
    
