classdef lazysnapping
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties(SetAccess = 'private')
        
        Mask     
        
    end
    
    properties (Access = 'private')
        
        Epsilon
        Lambda
        
        InputImage
        NumRows
        NumCols
        NumZDim
        NumChannels
        is3D
        
        SuperpixelGraph
        SourceNode
        TerminalNode
        UnaryEnergyForeground
        UnaryEnergyBackground
        PairwiseEnergy
        SuperpixelLabelMatrix
        NumSuperpixels   
        PixelIdxList
        MeanSuperpixelFeatures
        
        ForegroundInd
        BackgroundInd
        
        NeighborStartNodes
        NeighborEndNodes
        
    end
    
    properties (Access = 'private', Dependent)
       
        ForegroundScribbleColor
        BackgroundScribbleColor
        
    end
    
    methods
        
        function foregroundColors = get.ForegroundScribbleColor(self)
                            
            foregroundColors = zeros([numel(self.ForegroundInd),self.NumChannels],class(self.InputImage));

            for channelVal = 1:self.NumChannels
                foregroundColors(:,channelVal) = self.InputImage(self.ForegroundInd + (channelVal-1)*(self.NumRows*self.NumCols))';
            end
            
        end
        
        function backgroundColors = get.BackgroundScribbleColor(self)
                            
            backgroundColors = zeros([numel(self.BackgroundInd),self.NumChannels],class(self.InputImage));
            
            for channelVal = 1:self.NumChannels
                backgroundColors(:,channelVal) = self.InputImage(self.BackgroundInd + (channelVal-1)*(self.NumRows*self.NumCols))';
            end  
            
        end
        
        function self = lazysnapping(inputImage,superpixelLabelMatrix,numSuperpixels,conn,lambda)
            
            % Convert to double or single precision
            if ~isfloat(inputImage)
                self.InputImage = im2double(inputImage);
            else
                self.InputImage = inputImage;
            end
            classIn = class(self.InputImage);            
            if ~strcmp(class(superpixelLabelMatrix),classIn)
                superpixelLabelMatrix = cast(superpixelLabelMatrix,classIn);
            end
                
            self.SuperpixelLabelMatrix = superpixelLabelMatrix;
            self.NumSuperpixels = double(numSuperpixels);           
            self.NumRows = size(inputImage,1);
            self.NumCols = size(inputImage,2);
            self.is3D = ndims(superpixelLabelMatrix) == 3;
            
            if self.is3D
                self.NumChannels = 1; % 3D image
                self.NumZDim = size(inputImage,3);
            else
                self.NumChannels = size(inputImage,3); % vector-valued image
                self.NumZDim = 1;
            end
            
            % Lazy Snapping algorithm assumes uint8 data range. Adjust
            % lambda to scaled image with range [0 1]
            self.Lambda = lambda/(255^2);
            self.Epsilon = self.Lambda/10000;
 
            % Label matrices with only a single label cannot return
            % anything other than a false mask because the subregion must
            % contain both a foreground and background mark. In this case,
            % bypass the algorithm and return a false mask.
            if self.NumSuperpixels > 1
                self = initialize(self,conn);
            else
                self = setFalseMask(self);
            end
            
        end
        
        function self = initialize(self,conn)
            
            % Build graph of connected superpixels
            [s,t] = images.lazysnapping.internal.buildGraphNodePairs(self.SuperpixelLabelMatrix,conn);
            self.SuperpixelGraph = graph(s,t);

            self.PixelIdxList = label2idx(self.SuperpixelLabelMatrix);
            
            self.MeanSuperpixelFeatures = images.lazysnapping.internal.meanSuperpixelFeatures(...
                self.InputImage,self.SuperpixelLabelMatrix,self.NumSuperpixels,self.NumChannels);
            
            self.NeighborStartNodes = self.SuperpixelGraph.Edges.EndNodes(:,1);
            self.NeighborEndNodes = self.SuperpixelGraph.Edges.EndNodes(:,2);
            
            % Modify graph to include terminal node connections to all superpixels
            self = addTerminalNodesToGraph(self);
            
            % Add Weights as a variable in the Edges table
            self = addDefaultWeightsToGraph(self);
            
        end
        
        function self = addDefaultWeightsToGraph(self)
            self.SuperpixelGraph.Edges.Weight = zeros(height(self.SuperpixelGraph.Edges),1);
        end
        
        function self = addNewScribbles(self,foregroundNew,backgroundNew)
            % Update state of algorithm to reflect additional scribble
            % information.            
            self.ForegroundInd = foregroundNew;
            self.BackgroundInd = backgroundNew;
            self = updateTerminalEdgeWeights(self);
            self = updateNeighborEdgeWeights(self);
            
        end
        
        function self = segment(self)
            
            % Compute max-flow/min-cut on graph
            [~,~,CS] = maxflow(self.SuperpixelGraph,self.SourceNode,self.TerminalNode);
            % CS is the vector of node indices that are partitioned with
            % the source node (foreground). Remove the source node from
            % this vector to leave only the nodes of foreground subregions
            CS(CS==self.SourceNode) = [];
            % Use subregion labeling to label each of the pixels in the
            % output mask that belong to the nodes identified in CS
            self = setFalseMask(self);
            for i = 1:numel(CS)
                self.Mask(self.PixelIdxList{CS(i)}) = true;
            end
            
        end
        
        function self = setFalseMask(self)
            self.Mask = false([self.NumRows self.NumCols self.NumZDim]);
        end
        
    end
    
    methods(Access = 'private')
        
        function self = computeUnaryWeights(self)
            
            [self.UnaryEnergyForeground,self.UnaryEnergyBackground] = deal(zeros(self.NumSuperpixels,1));
            
            % Hard constraints based on user scribbles. Locations that were
            % marked as foreground or background must end up assigned as
            % foreground or background.
            hardForegroundInd = unique(self.SuperpixelLabelMatrix(self.ForegroundInd));
            hardBackgroundInd = unique(self.SuperpixelLabelMatrix(self.BackgroundInd));
            
            % Remove scribbles drawn on background regions of the label matrix
            hardForegroundInd(hardForegroundInd == 0) = [];
            hardBackgroundInd(hardBackgroundInd == 0) = [];
            
            if isempty(hardForegroundInd) || isempty(hardBackgroundInd)
                error(message('images:lazysnapping:invalidLabelMatrix'))
            end
            
            % Set hard constraints
            self.UnaryEnergyForeground(hardBackgroundInd) = Inf;
            self.UnaryEnergyBackground(hardForegroundInd) = Inf;
            
            % The ordering matters for regions labeled with both foreground
            % and background scribbles. Any region with both foreground and
            % background scribbles will have both unary weights set to
            % zero. This has the same effect as if the user had never
            % marked this region.
            self.UnaryEnergyForeground(hardForegroundInd) = 0;
            self.UnaryEnergyBackground(hardBackgroundInd) = 0;

            minDistanceToForegroundColor = images.lazysnapping.internal.minpdist2mex(self.ForegroundScribbleColor,self.MeanSuperpixelFeatures);
            minDistanceToBackgroundColor = images.lazysnapping.internal.minpdist2mex(self.BackgroundScribbleColor,self.MeanSuperpixelFeatures);

            softInd = 1:self.NumSuperpixels;
            softInd = setdiff(softInd,hardForegroundInd);
            softInd = setdiff(softInd,hardBackgroundInd);
            
            normTerm = minDistanceToForegroundColor(softInd) + minDistanceToBackgroundColor(softInd);
            self.UnaryEnergyForeground(softInd) = minDistanceToForegroundColor(softInd) ./ normTerm;
            self.UnaryEnergyBackground(softInd) = minDistanceToBackgroundColor(softInd) ./ normTerm;
            
            % If foreground, background, and mean superpixel values are
            % identical, the min distance and normTerm will be zero,
            % resulting in a NaN edge weight. Catch NaN edge weights and
            % set them to zero.
            self.UnaryEnergyForeground(isnan(self.UnaryEnergyForeground)) = 0;
            self.UnaryEnergyBackground(isnan(self.UnaryEnergyBackground)) = 0;
            
        end
        
        function self = updateTerminalEdgeWeights(self)
           
            self = computeUnaryWeights(self);
            
            t = 1:self.NumSuperpixels;
            edgeInd = findedge(self.SuperpixelGraph, self.SourceNode, t);
            
            self.SuperpixelGraph.Edges.Weight(edgeInd) = self.UnaryEnergyBackground;
            
            edgeInd = findedge(self.SuperpixelGraph, self.TerminalNode, t);
            self.SuperpixelGraph.Edges.Weight(edgeInd) = self.UnaryEnergyForeground;
            
        end
        
        function self = updateNeighborEdgeWeights(self)
                        
            startNodes = self.NeighborStartNodes;
            endNodes = self.NeighborEndNodes;
            
            temp = (self.MeanSuperpixelFeatures(startNodes,:)-self.MeanSuperpixelFeatures(endNodes,:)).^2;
            Cij = sum(temp,2);
            
            edgeInd = findedge(self.SuperpixelGraph, startNodes, endNodes);
            self.SuperpixelGraph.Edges.Weight(edgeInd) = self.Lambda./(self.Epsilon+(Cij));
                        
        end
        
        function self = addTerminalNodesToGraph(self)
            
            % Modify graph to include S and T nodes to define background and foreground
            numGridNodes = self.NumSuperpixels;
            self.SuperpixelGraph = addnode(self.SuperpixelGraph,2);
            self.SourceNode = numGridNodes+1;
            self.TerminalNode = numGridNodes+2;
            
            % Add T-nodes connected to S
            self.SuperpixelGraph = addedge(self.SuperpixelGraph,...
                self.SourceNode,...
                1:numGridNodes);
            
            % Add T-nodes connected to T.
            self.SuperpixelGraph = addedge(self.SuperpixelGraph,...
                self.TerminalNode,...
                1:numGridNodes);
            
        end
        
    end
    
end