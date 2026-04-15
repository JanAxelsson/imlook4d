classdef Rotation
% Representation of a 3D rotation    
  
    properties (SetAccess = public, GetAccess = public)
        % A quaternion description of the rotation.
        % q = [q0 q1 q2 q3] = [a b c d] = a + b*i + c*j + d*k
        quaternion;
        % The tolerance for which two rotations are considered equal. 
        % The comparison always applies to a quarternion representation of the
        % rotation. Represented as [qx qy qz q4] such that its norm is 1.
        tolerance;
    end
    
    properties (Constant = true)
       % If the quaternion differs less than this value from unity it is
       % normalized. Otherise an error is reported.
       tolNormalize = 1e-6; 
    end
    
    properties (Dependent = true, SetAccess = public, GetAccess = public)
        % A matrix description of the rotation.
        matrix;
        % A axis-angle description of the rotation [rad].
        axisAngle;
    end
    
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        % The rotation axis of the rotation. 
        % Arbitrarly chosen in as z-axis if the rotation angle is 0.
        axis;
        % The rotation angle (rad)
        angle;
    end
    
    % Set and get for the properties
    methods
        function obj = set.matrix(obj,m)
            % Convert to quaternion and assign. Implicit check of matrix.
            obj.quaternion = obj.matrix2Quaternion(m);
        end
        function obj = set.axisAngle(obj,aa)
            % Convert to quaternion and assign. Implicit check of aa.
            obj.quaternion = obj.axisAngle2Quaternion(aa);
        end
        function m = get.matrix(obj)
            m = obj.quaternion2Matrix(obj.quaternion);
        end
        function aa = get.axisAngle(obj)
            aa = obj.quaternion2AxisAngle(obj.quaternion);
        end
        function obj = set.tolerance(obj,val)
            if (val<0 || val > 1)
               error('The tolerance must belong to the interval: [0,1]') 
            end
            obj.tolerance = val;
        end
        
        function theta = get.angle(obj)
            theta = norm(obj.axisAngle);
        end
        
        function a = get.axis(obj)
            aa = obj.axisAngle;
            theta = norm(aa);
            if (theta == 0)
                a = [0 0 1]';
            else
                a = aa/theta;
            end
        end
    end
    
    % Construction
    methods
        function obj = Rotation(varargin)
            % Construct a Rotation object.
            % The object can be constructed from a quaternion, a matrix, a
            % axis angle description or euler angles in arbitrary
            % directions and order for both internal and external
            % coordinate systems.
            %
            % Quaternion initialization
            % Inpar:
            % q - A quaternion 1 x 4 / 4 x 1 
            %     q = [q0 q1 q2 q3] -> q0 + q1*i + q2*j + q3*k
            % normalize - Optional (defualt = false). Normalize the
            %             quaternion if true.
            %
            %
            % Matrix initialization
            % Inpar:
            % m - A matrix (3 x 3) must be a rotation.
            %
            % Axis-angle initialization
            % axisAngle - A 1 x 3 or 3 x 1 vector (rad)
            %
            % Euler angle initilization
            % eulerAngle - 1 x 3 or 3 x 1 vector. First angle is applied
            %              first in the transform.
            % coords     - 1 x 3 string of coordinate axis x,y and z. E.g.
            %              'xyz' or 'xyx'.
            % int_ext    - Specify if a internal or external (fixed)
            %              coordinate system is used for the rotation. Use
            %              'internal' or 'external'
            
            % Set the tolerance to default
            obj.tolerance = 1e-6;
            
            switch (nargin)
                case 0
                    obj.quaternion = [1 0 0 0]';
                case 1
                    if (isequal(size(varargin{1}),[3 3]))
                       obj.matrix = varargin{1};
                    elseif (numel(varargin{1})==3)
                       obj.axisAngle = varargin{1}; 
                    else
                       q = varargin{1};
                       q = q(:);
                       
                       % Check the quaternion for obvios flaws
                       if (~isequal(size(q),[4 1]))
                          error('Rotation:Rotation','Wrong dimensions on the quaternion input.'); 
                       end
                        
                       % Check that the quaternion is normalized. If small deviation.
                       % Normlize. Otherwise through on error.
                       if (abs(norm(q)-1) > Rotation.tolNormalize)
                        error('Rotation:quaternion2AxisAngle','The quaternion is not normalized');
                       else
                        q = q/norm(q);
                       end
                       
                       obj.quaternion = q; 
                    end
                case 2
                       q = varargin{1};
                       q = q(:);
                       
                       % Check the quaternion for obvios flaws
                       if (~isequal(size(q),[4 1]))
                          error('Rotation:Rotation','Wrong dimensions on the quaternion input.'); 
                       end
                        
                       if (varargin{2})
                           q = q/norm(q);
                       else
                           % Check that the quaternion is normalized. If small deviation.
                           % Normlize. Otherwise through on error.
                           if (abs(norm(q)-1) > Rotation.tolNormalize)
                            error('Rotation:quaternion2AxisAngle','The quaternion is not normalized');
                           else
                            q = q/norm(q);
                           end
                       end
                       
                    obj.quaternion = q; 
                case 3
                    obj.quaternion = obj.eulerAngles2Quaternion(varargin{1},varargin{2},varargin{3});
                otherwise
                    error('Rotation:Rotation','Wrong number of input arguments to the Rotation constructor.')
            end
            
            
        end
    end
    
    % Static methods
    methods (Static = true)
        function rArray = identities(varargin)
            % Create an array of identity rotations
            % Input:
            % siz - A vector 1 x n with dimension sizes
            % 
            % or
            %
            % n1,n2,...nk - Dimension sizes
            
            switch (nargin)
                case 0
                    error('Rotation:identities','At least one input argument is required');
                case 1    
                    if (isscalar(varargin{1}))
                       % Scalar input is interpreted as N x N
                       rArray = Rotation.empty(varargin{1},0);
                       rArray(varargin{1},varargin{1}) = Rotation();
                    else
                       rArray = Rotation.empty([varargin{1}(1:(end-1)),0]);      
                       index = num2cell(varargin{1});
                       rArray(index{:}) = Rotation();  
                    end
                otherwise
                       rArray = Rotation.empty([[varargin{1:(end-1)}],0]);
                       rArray(varargin{:}) = Rotation();
            end
            
        end
        function m = eulerAngles2Matrix(eulerAngle,coords,int_ext) 
            % Convert Euler angle representation to a matrix representation.
            % Input:
            % eulerAngle - 1 x 3 or 3 x 1 vector (rad)
            % coords - Coordiantes, e.g. 'xyz', 'xyx', ...
            % int_ext - 'internal', 'external'. Referes to the coordinate system used
            
            m = quaternion2Matrix(eulerAngle2Quaternion(eulerAngle,coords,int_ext));

        end
        
        function aa = eulerAngles2AxisAngle(eulerAngle,coords,int_ext)
            % Convert Euler angle representation to a axis angle representation.
            % Input:
            % eulerAngle - 1 x 3 or 3 x 1 vector (rad)
            % coords - Coordiantes, e.g. 'xyz', 'xyx', ...
            % int_ext - 'internal', 'external'. Referes to the coordinate system used
            
            aa = quaternion2AxisAngle(eulerAngle2Quaternion(eulerAngle,coords,int_ext));
            
        end
        
        function q = eulerAngles2Quaternion(eulerAngle,coords,int_ext)
            % Convert Euler angle representation to a axis angle
            % representation. OBS: The first coordinate is applied first.
            % Input:
            % eulerAngle - 1 x 3 or 3 x 1 vector (rad)
            % coords - Coordiantes, e.g. 'xyz', 'xyx', ...
            % int_ext - 'internal', 'external'. Referes to the coordinate system used
            
            % Check input
           if (~(isequal(size(eulerAngle),[1 3]) || isequal(size(eulerAngle),[3 1])))
              error('Rotation:eulerAngles2Quaternion','Wrong dimensions on the eulerAngle input.'); 
           end
           
           if (~isequal(class(coords),'char') || numel(coords)~= 3)
              error('Rotation:eulerAngles2Quaternion','Bad coordinate specification. Should be e.g. ''xyz'''); 
           end
           
           switch (lower(int_ext))
               case 'internal'
                   
                   % First rotation about coords(1)
                   q1 = Rotation.axisAngle2Quaternion(Rotation.singleAxisAngle(eulerAngle(1),coords(1)));
                   
                   % Get second rotation axis
                   e2 = Rotation.getRotAxis(coords(2));
                   
                   % Transform it with q1
                   e2 = Rotation.quaternion2Matrix(q1)*e2;
                   
                   % Second rotation
                   q2 = Rotation.axisAngle2Quaternion(e2*eulerAngle(2));
                   
                   % Get third rotation axis
                   e3 = Rotation.getRotAxis(coords(3));
                   
                   % Transform it 
                   e3 = Rotation.quaternion2Matrix(q2)*Rotation.quaternion2Matrix(q1)*e3;
                   
                   % Third rotation
                   q3 = Rotation.axisAngle2Quaternion(e3*eulerAngle(3));
                   
               case 'external'
                   % A fix external coordinate system
                   q1 = Rotation.axisAngle2Quaternion(Rotation.singleAxisAngle(eulerAngle(1),coords(1)));
                   q2 = Rotation.axisAngle2Quaternion(Rotation.singleAxisAngle(eulerAngle(2),coords(2)));
                   q3 = Rotation.axisAngle2Quaternion(Rotation.singleAxisAngle(eulerAngle(3),coords(3)));

               otherwise
                   error('Rotation:eulerAngles2Quaternion','The transformation type must be: ''internal'' or ''external''');
           end
            

           % Create the combined rotation quaternion
           q = Rotation.multQuaternion(q3,Rotation.multQuaternion(q2,q1));
            
        end

        function aa = matrix2AxisAngle(m)
            % Convert a matrix representation of a 3D rotation to an axis-angle representation. 
            aa = Rotation.quaternion2AxisAngle(Rotation.matrix2Quaternion(m));
        end
        
        function q = matrix2Quaternion(m)
            % Check the matrix
            if (~isequal(size(m),[3 3]))
              error('Rotation:matrix2Quaternion','Wrong dimensions on the matrix input.'); 
            end
            
            
            
            % Create quaternion - OBS reversed order
            % of index. Also, this quaternion has q(4) as the real element.
            K = 1/3*[m(1,1)-m(2,2)-m(3,3), m(1,2)+m(2,1), m(1,3)+m(3,1), m(3,2)-m(2,3);...
                     m(1,2)+m(2,1), m(2,2)-m(1,1)-m(3,3),m(3,2)+m(2,3), m(1,3)-m(3,1);...
                     m(1,3)+m(3,1), m(2,3)+m(3,2), m(3,3)-m(1,1)-m(2,2), m(2,1)-m(1,2);...
                     m(3,2)-m(2,3), m(1,3)-m(3,1), m(2,1)-m(1,2), m(1,1)+m(2,2)+m(3,3)];
                 
            [v,d] = eig(K);
            [maxEigVal,maxEig] = max(diag(d));
            
            % The maximal eigenvalue should be very close to 1
            if (abs(maxEigVal-1)>Rotation.tolNormalize)
               error('Rotation:matrix2Quaternion','The matrix was not a rotational matrix since the resulting quaternion was not normalized.'); 
            end
            
            q = v(:,maxEig);
            
            q = [q(4),q(1:3)'];
            
            if (abs(norm(q)-1) > Rotation.tolNormalize)
               error('Rotation:matrix2Quaternion','The matrix was not a rotational matrix since the resulting quaternion was not normalized.');
            else
               q = q/norm(q);
            end
            
            
        end
        
        function aa = quaternion2AxisAngle(q)
           % Convert a quaternion representation of a 3D rotation to an axis-angle representation. 
           
           % Check the quaternion for obvios flaws
           if (~(isequal(size(q),[1 4]) || isequal(size(q),[4 1])))
              error('Rotation:quaternion2AxisAngle','Wrong dimensions on the quaternion input.'); 
           end
           
           q = q(:);
           
           % Check that the quaternion is normalized. If small deviation.
           % Normlize. Otherwise through on error.
           if (abs(norm(q)-1) > Rotation.tolNormalize)
               error('Rotation:quaternion2AxisAngle','The quaternion is not normalized');
           else
               q = q/norm(q);
           end
           
           theta = 2*acos(q(1));
           
           % Theta must be within [-pi,pi]
           if (theta > pi)
              theta = theta-2*pi; 
           end
  
           if (theta ~= 0)
            e = q(2:4)/norm(q(2:4));
           else
            e = [0 0 0]'; 
           end
           aa = e*theta;
        end
        
        function m = quaternion2Matrix(q)
        % Convert a quaternion representation of a 3D rotation to a matrix representation. 
           
           % Check the quaternion for obvios flaws
           if (~(isequal(size(q),[1 4]) || isequal(size(q),[4 1])))
              error('Rotation:quaternion2AxisAngle','Wrong dimensions on the quaternion input.'); 
           end
           
           q = q(:);
           
           % Check that the quaternion is normalized. If small deviation.
           % Normlize. Otherwise through on error.
           if (abs(norm(q)-1) > Rotation.tolNormalize)
               error('Rotation:quaternion2AxisAngle','The quaternion is not normalized');
           else
               q = q/norm(q);
           end  
           
           qhat = q(2:4);
           Q = [0 -q(4) q(3); q(4) 0 -q(2); -q(3) q(2) 0];
           
           m = (q(1)^2-qhat'*qhat)*eye(3) + 2*(qhat*qhat') + 2*q(1)*Q;     
        end
        
        function m = axisAngle2Matrix(axisAngle)
            % Convert a axis-angle representation of a 3D rotation to a matrix.
            m = Rotation.quaternion2Matrix(Rotation.axisAngle2Quaternion(axisAngle));
        end
        
        function q = axisAngle2Quaternion(axisAngle)
            % Convert an axis-angle representation of a 3D rotation to quaternion representation.
            
            % Check the axis angle input
            if (numel(axisAngle) ~= 3)
                error('Rotation:axisAngle2Quaternion','Wrong dimensions on the axis-angle input.');        
            end
            
            % Uniform usage
            axisAngle = axisAngle(:);
            
            
            if (isequal(axisAngle,[0 0 0]'))
                % Special case
                q = [1 0 0 0]';
            else
                % General case
                theta = norm(axisAngle);
                e = axisAngle./theta;
                
                % Theta must be within [-pi,pi]
                theta = mod(theta,2*pi);
                if (theta > pi)
                   theta = theta-2*pi; 
                end
                
                q = [cos(theta/2); e*sin(theta/2)];
            end
        end
    end
    
    % Private static methods
    methods (Access = private, Static = true)
        function aa = singleAxisAngle(theta,rotAxis)
                aa = Rotation.getRotAxis(rotAxis)*theta;
        end
        
        function a = getRotAxis(rotAxis)
           switch (lower(rotAxis))
               case 'x'
                   a = [1 0 0]';
               case 'y'
                   a = [0 1 0]';
               case 'z'
                   a = [0 0 1]';
               otherwise
                   error('Rotation:getRotAxis',['Unknown rotation axis: ', rotAxis]);
           end
            
        end
        
        function q = multQuaternion(q1,q2)
            Q = [q2(1) -q2(2) -q2(3) -q2(4);...
                 q2(2) q2(1) q2(4) -q2(3);...
                 q2(3) -q2(4) q2(1) q2(2);...
                 q2(4) q2(3) -q2(2) q2(1)];
             
             q = Q*q1(:);
             
             % Normalize to ensure exact rotation properties.
             q = q./norm(q);
        end
        
    end
    
    % Ordinary public methods
    methods (Access = public)
        
        function z = times(x,y)
        % Multiply arrays of rotations with arrays of rotations, elementwise.
        % R2*.R1 - Produces rotations corresponding to first applying
        %          R1 and then R2.
        if (isa(x,'Rotation') && isa(y,'Rotation'))
            if (numel(x) == 1)
              z = y;
              for ii = 1:numel(y)
                z(ii).quaternion = Rotation.multQuaternion(x.quaternion,y(ii).quaternion);  
                z(ii).tolerance = x.tolerance;
              end
            elseif (numel(y) == 1)
              z = x;
              for ii = 1:numel(x)
                z(ii).quaternion = Rotation.multQuaternion(x(ii).quaternion,y.quaternion);  
              end    
            elseif (isequal(size(x),size(y)))
              z = x;
              for ii = 1:numel(x)
                z(ii).quaternion = Rotation.multQuaternion(x(ii).quaternion,y(ii).quaternion);  
              end   
            else
               error('Rotation:times','Dimension missmatch in the operation x.*y.'); 
            end
        else
           error('Rotation:times','Both x and y must be rotations in the expression x*y.') 
        end
        
        end
        
        function z = mtimes(x,y)
        % Multiply rotations with rotations or with vectors (3D).
        % R2*R1 - Produces a new rotation corresponding to first applying
        %         R1 and then R2.
        % R*v   - Produces a rotated v. v is (3 x n)
        % v*R   - Produces a rotated v. v is (n x 3)
           if (isa(x,'Rotation') && isa(y,'Rotation')) 
               % One of the rotations must be scalar.
               if (numel(x) == 1 || numel(y) == 1)
                   if (numel(x) == 1)
                      z = y;
                      for ii = 1:numel(y)
                        z(ii).quaternion = Rotation.multQuaternion(x.quaternion,y(ii).quaternion);  
                        z(ii).tolerance = x.tolerance;
                      end
                   else 
                      z = x;
                      for ii = 1:numel(x)
                        z(ii).quaternion = Rotation.multQuaternion(x(ii).quaternion,y.quaternion);  
                      end  
                   end
               else
                  error('Rotation:mtimes','At least one of the inputs must be a scalar rotation'); 
               end
           elseif(isa(x,'Rotation'))
               % x must be scalar
               if (~isscalar(x))
                  error('Rotation:mtimes','x*y - x must be a scalar rotation when y is 3D vectors.'); 
               end
               % Check y
               if (isnumeric(y) && (numel(size(y)) == 2) && (size(y,1)== 3))
                z = x.matrix * y; 
               else
                   error('Rotation:mtimes','The second argument is not a valid collection of 3D vectors.');
               end
           elseif (isa(y,'Rotation'))
               if (~isscalar(y))
                  error('Rotation:mtimes','x*y - y must be a scalar rotation when x is 3D vectors.'); 
               end
               % Check x
               if (isnumeric(x) && (numel(size(x)) == 2) && (size(x,2)== 3))
                z = x * y.matrix; 
               else
                   error('Rotation:mtimes','The first argument is not a valid collection of 3D vectors.');
               end
           else
               error('Rotation:mtimes','Bad input to mtimes');
           end
        end
    
        function tf = ne(obj1,obj2)
            % Check if rotations are not equal within tolerance. 
            
            % Cannot use the quaternion since it is not unique. Use the axis angle.
            if (~(isa(obj1,'Rotation') && isa(obj2,'Rotation')))
               error('Rotation:neq','Rotations can only be compared to Rotations.') 
            end
            if (isequal(size(obj1),size(obj2)))
                tf = zeros(size(obj1));
                for ii = 1:numel(obj1)
                    tf(ii) = norm(obj1(ii).axisAngle - obj2(ii).axisAngle) > obj1(ii).tolerance;
                end
            elseif (numel(obj1)==1)
                tf = zeros(size(obj2));
                for ii = 1:numel(obj2)
                    tf(ii) = norm(obj1.axisAngle - obj2(ii).axisAngle) > obj1.tolerance;
                end
            elseif (numel(obj2)==1)
                tf = zeros(size(obj1));
                for ii = 1:numel(obj1)
                    tf(ii) = norm(obj1(ii).axisAngle - obj2.axisAngle) > obj1(ii).tolerance;
                end
            else
                error('Rotation:neq','Dimension missmatch during A==B');
            end
        end
        
        function tf = eq(obj1,obj2)
            % Check if rotations are equal within tolerance. 
            
            % Cannot use the quaternion since it is not unique. Use the axis angle.
            if (~(isa(obj1,'Rotation') && isa(obj2,'Rotation')))
               error('Rotation:eq','Rotations can only be compared to Rotations.') 
            end
            if (isequal(size(obj1),size(obj2)))
                tf = zeros(size(obj1));
                for ii = 1:numel(obj1)
                    tf(ii) = norm(obj1(ii).axisAngle - obj2(ii).axisAngle) <= obj1(ii).tolerance;
                end
            elseif (numel(obj1)==1)
                tf = zeros(size(obj2));
                for ii = 1:numel(obj2)
                    tf(ii) = norm(obj1.axisAngle - obj2(ii).axisAngle) <= obj1.tolerance;
                end
            elseif (numel(obj2)==1)
                tf = zeros(size(obj1));
                for ii = 1:numel(obj1)
                    tf(ii) = norm(obj1(ii).axisAngle - obj2.axisAngle) <= obj1(ii).tolerance;
                end
            else
                error('Rotation:eq','Dimension missmatch during A==B');
            end
        end
        
        function obj = mpower(y,x)
           % y^x : Take the rotation y to the power x. 
           % Both x and y must be scalar.
           
           if (isscalar(x) && isscalar(y))
              obj = y.^x; 
           else
               error('Rotation:mpower','Both x and y must be scalar in the expression x^y');
           end
           
        end
        
        function obj = power(y,x)
            % y.^x : Take the rotation y to the power x which is real
            
            % Check input
            if (~(isequal(class(x),'double') || isequal(class(x),'single')))
               error('Rotation:power','The exponent must be a single or double.') 
            end
            
            if (numel(x) ~= 1 && ((numel(x) ~= numel(y)) && (numel(y)~=1)))     
               error('Rotation:power','Dimension missmatch between base and exponent.')  
            end
            
            % Exponentiate
            if (numel(y)==1)
                siz = size(x);
                obj = Rotation.identities(siz);
            else
                obj = y;
            end
            
            if (numel(y) > numel(x))
               x = ones(size(y))*x; 
            end
            
            if (numel(y)==1)
                for ii = 1:numel(obj)
                    obj(ii).axisAngle = y.axisAngle*x(ii);
                end
            else
                for ii = 1:numel(obj)
                    obj(ii).axisAngle = y(ii).axisAngle*x(ii);
                end
            end
        end
        
        function iR = inv(R)
            % This function inverts a rotation.    
            iR = R;
            for ii = 1:numel(R) 
                iR(ii).quaternion(2:4) = -R(ii).quaternion(2:4);
            end
        end
    end
    
end

%%%#Public: "Utils"
