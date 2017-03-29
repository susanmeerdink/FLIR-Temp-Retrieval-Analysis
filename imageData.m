classdef imageData < handle 
    properties
        queue   %This is a cells w/ format {"fileInfo","fileInfo","fileInfo"}. Example: imageBatchQueue.queue{1}.name
        queueImageCount  % this is the number of images in the queue
        queueIndex      % hold a number that points to the image that has been currently loaded into fileInfo
        tempSub_queue % holds the temp_sub output of integer2temp function
        emiss_queue %holds the emmisivity matrix
        %------Output variables for combined table output--------
        tableFileName_queue % this is file source for the variables
        dateOrig_queue % stores date when the image was captured. year:month:day Example: 2015:02:20
        timeOrig24_hour_min_sec_queue % stores time when the image was captured. hours:minutes:seconds Example:19:47:21.361+00:00
        % Uncorrected temperature and calculate the Scene average
        Avg_unCorTem_queue                          %Scene average temperature assuming BB 
        % Exitance calculated from Temperature at BlactBody
        Avg_Exit_at_BB_queue                        %Scene average Exitance at BB
        Scene_temp_calcul_from_Avg_exit_at_BB_queue %calculate scene temperature from Avg_exitance
        % Exitance after correcting down welling Radiance and assuming emissivity of 0.95
        Avg_Surf_exit_queue                         %the 'DWR' may be varing with time of day and with atmospheric condition.  
        Scene_temp_calcul_from_Avg_Surf_exit_queue
        % Temperature after corecting for DWR and assuming emissivity 0.95
        Scene_temp_at_Emiss_95_queue
        % Retriving surface Exitance using pixel based emissivity and correcting for DWR
        Scene_emiss_queue % average (scene) emissivity
        Avg_Surf_exit_using_class_emiss_queue
        Scene_temp_calcul_from_Avg_Surf_exit_using_Scene_emiss_queue
        % Surface Temperature using pixel based emissivity and  applying DWR corrections
        Avg_Surf_temp_using_class_emiss_queue
        
        % Emissivity Values
        NPV_Value
        GV_Value
        Shade_Value
        DWR_Value
        
        Data_Output_Table_queue % This is the output of all the values that were calculated
        
    end
    methods
        function obj = imageData(im_data)   % Constructor for new class objects
            obj.queue = im_data;
            obj.queueImageCount = 0;
            obj.queueIndex = 0;
            obj.tempSub_queue = [];
            obj.emiss_queue = [];
        end
        function storeImage(obj)
            obj.queueIndex = obj.queueIndex+1;
            obj.queueImageCount = obj.queueImageCount+1;
            global fileInfo
            obj.queue{obj.queueIndex} = fileInfo;
        end
        function queueReset(obj)   %resets queueIndex to the first image and loads it into fileInfo
            global imageBatchQueue
            imageBatchQueue.queueIndex = 1;
        end
        function file = queueNext(obj)      %loads the next image in the queue into fileInfo
                global fileInfo
                global temp_sub
                global emiss
                global imageBatchQueue
                imageBatchQueue.queue{imageBatchQueue.queueIndex} = fileInfo;   %stores the current image
                imageBatchQueue.tempSub_queue{imageBatchQueue.queueIndex} = temp_sub; %stores the current temp_sub
                imageBatchQueue.emiss_queue{imageBatchQueue.queueIndex} = emiss; % stores the current emissivity matrix
            if imageBatchQueue.queueIndex < imageBatchQueue.queueImageCount     %check if the current image is the last
                imageBatchQueue.queueIndex = imageBatchQueue.queueIndex+1;      %increasements the index
                file = imageBatchQueue.queue{imageBatchQueue.queueIndex};       %loads the next image into fileInfo  
            else
                file = imageBatchQueue.queue{imageBatchQueue.queueIndex};       %if last image is already loaded, just returns same
            end
        end
    end
end
