classdef Morphop_ocv_Buildable < coder.ExternalDependency %#codegen
    % Encapsulate morphop implementation library
    
    % Copyright 2016 The MathWorks, Inc.
    
    %#ok<*EMCA>
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Morphop_ocv_Buildable';
        end
        
        function b = isSupportedContext(context)
            b = context.isMatlabHostTarget();
        end
        
        function updateBuildInfo(buildInfo,context)
            % File extensions
            [linkLibPath, linkLibExt, execLibExt] = ...
                context.getStdLibInfo();
            group = 'BlockModules';
            
            % Header paths
            buildInfo.addIncludePaths(fullfile(matlabroot,'extern','include'));
            
            % Platform specific link and non-build files
            arch      = computer('arch');
            binArch   = fullfile(matlabroot,'bin',arch,filesep);
            sysOSArch = fullfile(matlabroot,'sys','os',arch,filesep);
            
            ocv_version = '3.1.0';
            
            libstdcpp = [];
            % include libstdc++.so.6 on linux
            if strcmp(arch,'glnxa64')
                libstdcpp = strcat(sysOSArch,{'libstdc++.so.6'});
            end
            
            switch arch
                case {'win64'}
                    libDir        = images.internal.getImportLibDirName(context);
                    linkLibPath   = fullfile(matlabroot,'extern','lib',arch,libDir);
                    linkFiles     = {'libmwmorphop_ocv'}; %#ok<*EMCA>
                    linkFiles     = strcat(linkFiles, linkLibExt);
                    
                                                                               
                    ocv_ver_no_dots = strrep(ocv_version,'.','');
                    
                    % Non-build files
                    % associate open cv 3p libraries in (matlabroot)\bin\win64
                    ocvNonBuildFilesNoExt =  {'opencv_calib3d', ...
                        'opencv_core', ...
                        'opencv_cudaarithm', ...
                        'opencv_cudabgsegm', ...
                        'opencv_cudafeatures2d', ...
                        'opencv_cudafilters', ...
                        'opencv_cudaimgproc', ...
                        'opencv_cudalegacy', ...
                        'opencv_cudaobjdetect', ...
                        'opencv_cudaoptflow', ...
                        'opencv_cudastereo', ...
                        'opencv_cudawarping', ....
                        'opencv_cudev', ...
                        'opencv_features2d', ...
                        'opencv_flann', ...
                        'opencv_highgui', ...
                        'opencv_imgproc', ...
                        'opencv_imgcodecs', ...
                        'opencv_ml', ...
                        'opencv_objdetect', ...
                        'opencv_photo', ...
                        'opencv_shape', ...
                        'opencv_stitching', ...
                        'opencv_superres', ...
                        'opencv_stitching', ...
                        'opencv_video', ...
                        'opencv_videoio', ...
                        'opencv_videostab'};
                    ocvNonBuildFilesNoExt = strcat(ocvNonBuildFilesNoExt, ocv_ver_no_dots);
                   
                    nonBuildFilesNoExt = [ocvNonBuildFilesNoExt, 'tbb','libmwmorphop_ocv'];
                    nonBuildFiles = strcat(binArch,nonBuildFilesNoExt, execLibExt);
                case {'glnxa64','maci64'}
                    ocv_major_ver = ocv_version(1:end-2);
                    ocvNonBuildFilesNoExt =  {'libopencv_calib3d', ...
                        'libopencv_core', ...
                        'libopencv_cudaarithm', ...
                        'libopencv_cudabgsegm', ...
                        'libopencv_cudafeatures2d', ...
                        'libopencv_cudafilters', ...
                        'libopencv_cudaimgproc', ...
                        'libopencv_cudalegacy', ...
                        'libopencv_cudaobjdetect', ...
                        'libopencv_cudaoptflow', ...
                        'libopencv_cudastereo', ...
                        'libopencv_cudawarping', ....
                        'libopencv_cudev', ...
                        'libopencv_features2d', ...
                        'libopencv_flann', ...
                        'libopencv_highgui', ...
                        'libopencv_imgproc', ...
                        'libopencv_imgcodecs', ...
                        'libopencv_ml', ...
                        'libopencv_objdetect', ...
                        'libopencv_photo', ...
                        'libopencv_shape', ...
                        'libopencv_stitching', ...
                        'libopencv_superres', ...
                        'libopencv_stitching', ...
                        'libopencv_video', ...
                        'libopencv_videoio', ...
                        'libopencv_videostab'};
                    
                    if strcmpi(arch,'glnxa64')
                        ocvNonBuildFilesNoExt{end+1} = 'libopencv_cudacodec';
                        nonBuildFiles = strcat(binArch,ocvNonBuildFilesNoExt, strcat('.so.',ocv_major_ver));
                        % Needed for linking
                        linkFiles = 'mwmorphop_ocv';
                        % Not needed while linking, just when running
                        nonBuildFiles{end+1} = strcat(binArch,'libtbb.so.2');
                        nonBuildFiles{end+1} = strcat(binArch,'libtbbmalloc.so.2');
                        nonBuildFiles{end+1} = strcat(binArch,'libmwmorphop_ocv.so');
                        
                    else % maci64
                        nonBuildFiles = strcat(binArch,ocvNonBuildFilesNoExt, strcat('.',ocv_major_ver,'.dylib'));
                        % Needed for linking
                        linkFiles = 'mwmorphop_ocv';
                        % Not needed while linking, just when running
                        nonBuildFiles{end+1} = strcat(binArch,'libtbb.dylib');
                        nonBuildFiles{end+1} = strcat(binArch,'libmwmorphop_ocv.dylib');
                    end
                    
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end
            
            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                linkPriority    = images.internal.coder.buildable.getLinkPriority('tbb');
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                    linkPrecompiled,linkLinkonly,group);
            end
            
            % Non-build files
            nonBuildFiles = [nonBuildFiles libstdcpp];
            % Add CUDA dependency
            nonBuildFiles = images.internal.coder.buildable.Morphop_ocv_Buildable.AddCUDALibs(nonBuildFiles, binArch);
            
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
            
        end
        
        function b = morphop_ocv(...
                fcnName, a, asize, nhood, nsize, b)
            coder.inline('always');
            coder.cinclude('libmwmorphop_ocv.h');
            
            coder.ceval(fcnName,...
                coder.rref(a), coder.rref(asize), ...
                coder.rref(nhood), coder.rref(nsize), ...
                coder.ref(b));
        end
        
        
        
        %==========================================================================
        function nonBuildFiles = AddCUDALibs(nonBuildFiles, pathBinArch)
            % CUDA: required by all OpenCV libs when OpenCV is built WITH_CUDA=ON.
            cudaLibs = {'cudart', 'nppc', 'nppi', 'npps','cufft'};
            
            arch = computer('arch');
            switch arch
                case 'win64'
                    cudaLibs = strcat(cudaLibs, '64_*.dll');
                case 'glnxa64'
                    cudaLibs = strcat('lib', cudaLibs, '.so.*.*');
                case 'maci64'
                    cudaLibs = strcat('lib', cudaLibs, '.*.*.dylib');
                otherwise
                    assert(false,[ arch ' operating system not supported']);
            end
            
            cudaLibs = lookupInBinDir(pathBinArch, cudaLibs);
            cudaLibs = strcat(pathBinArch,cudaLibs);
            nonBuildFiles = [nonBuildFiles, cudaLibs];
            
            
            function libs = lookupInBinDir(pathBinArch, libs)
                for ind = 1:numel(libs)
                    % expand to get real file name
                    info = dir(fullfile(pathBinArch, libs{ind}));
                    libs{ind} = info(1).name;
                end
            end
        end
    end
end