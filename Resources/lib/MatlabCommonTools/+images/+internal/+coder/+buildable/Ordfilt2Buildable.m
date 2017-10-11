classdef Ordfilt2Buildable < coder.ExternalDependency %#codegen
    %ORDFILT2BUILDABLE - Encapsulate ordfilt2 implementation library
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        
        function name = getDescriptiveName(~)
            name = 'Ordfilt2Buildable';
        end
        
        function b = isSupportedContext(context)
            b = context.isMatlabHostTarget();
        end
        
        function updateBuildInfo(buildInfo, context)
            % File extensions
            [~, linkLibExt, execLibExt] = ...
                context.getStdLibInfo();
            group = 'BlockModules';
            
            % Header paths
            buildInfo.addIncludePaths(fullfile(matlabroot,'extern','include'));
            
            % Platform specific link and non-build files
            arch      = computer('arch');
            binArch   = fullfile(matlabroot,'bin',arch,filesep);
            sysOSArch = fullfile(matlabroot,'sys','os',arch,filesep);

            libstdcpp = [];
            % include libstdc++.so.6 on linux
            if strcmp(arch,'glnxa64')
                libstdcpp = strcat(sysOSArch,{'libstdc++.so.6'});
            end

            switch arch
                case {'win32','win64'}
                    linkFiles   = {'libmwordfilt2'}; %#ok<*EMCA>
                    linkFiles   = strcat(linkFiles, linkLibExt);
                    libDir      = images.internal.getImportLibDirName(context);
                    linkLibPath = fullfile(matlabroot,'extern','lib',arch,libDir);
                    
                case {'glnxa64','maci64'}
                    linkFiles   = {'mwordfilt2'}; %#ok<*EMCA>
                    linkLibPath = binArch;
                
                otherwise
                    % unsupported
                    assert(false,[arch ' operating system not supported']);
            end

            if coder.internal.hostSupportsGccLikeSysLibs()
                buildInfo.addSysLibs(linkFiles, linkLibPath, group);
            else
                linkPriority    = '';
                linkPrecompiled = true;
                linkLinkonly    = true;
                buildInfo.addLinkObjects(linkFiles,linkLibPath,linkPriority,...
                                         linkPrecompiled,linkLinkonly,group);
            end
            
            % Non-build files
            nonBuildFiles = {'libmwordfilt2'};            
            nonBuildFiles = strcat(binArch,nonBuildFiles, execLibExt);
            nonBuildFiles = [nonBuildFiles libstdcpp];
            buildInfo.addNonBuildFiles(nonBuildFiles,'',group);
                        
        end
        
        
        function B = ordfilt2core(fcnName, A, order, offsets, startIdx, domainSize, B)
            coder.inline('always');
            coder.cinclude('libmwordfilt2.h');
            coder.ceval(fcnName,...
                coder.rref(A),...
                size(A,1),...
                coder.rref(startIdx),...
                coder.rref(offsets), ...
                numel(offsets), ...
                coder.rref(domainSize), ...
                order, ...              
                coder.ref(B),...
                size(B));
       end
       
       function B = ordfilt2offsetscore(fcnName, A, order, offsets, startIdx, domainSize, s, B)
            coder.inline('always');
            coder.cinclude('libmwordfilt2.h');
            coder.ceval(fcnName,...
                coder.rref(A),...
                size(A,1),...
                coder.rref(startIdx),...
                coder.rref(offsets), ...
                numel(offsets), ...
                coder.rref(domainSize), ...
                order, ...  
                coder.rref(s) , ...
                coder.ref(B),...
                size(B));
       end

        
    end
end
