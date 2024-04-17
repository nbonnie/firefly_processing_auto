function test(varargin)

disp(nargin)

if nargin > 0
    PATH = varargin{1};
end

disp("PATH IS")
disp(PATH)
quit
end

% matlab -nodesktop -nosplash -r "test 'testing'"