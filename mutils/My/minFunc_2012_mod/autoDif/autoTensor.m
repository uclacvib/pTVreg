function [f,g,H,T] = autoTensor(x,type,funObj,varargin)
% [f,g,H,T] = autoTensor(x,useComplex,funObj,varargin)
% Numerically compute Tensor of 3rd-derivatives of objective function from Hessian values

p = length(x);

if type == 2
	mu = 2*sqrt(1e-12)*(1+norm(x));
    
	f1 = zeros(p,1);
	f2 = zeros(p,2);
	g1 = zeros(p);
	g2 = zeros(p);
    diff = zeros(p,p,p);
    for j = 1:p
        e_j = zeros(p,1);
        e_j(j) = 1;
        [f1(j) g1(:,j) diff1(:,:,j)] = funObj(x + mu*e_j,varargin{:});
        [f2(j) g2(:,j) diff2(:,:,j)] = funObj(x + mu*e_j,varargin{:});
	end
	f = mean([f1;f2]);
	g = mean([g1 g2],2);
	H = mean(cat(3,diff1,diff2),3);
	T = (diff1-diff2)/(2*mu);
elseif type == 3 % Use Complex Differentials
    mu = 1e-150;

	f = zeros(p,1);
	g = zeros(p);
    diff = zeros(p,p,p);
    for j = 1:p
        e_j = zeros(p,1);
        e_j(j) = 1;
        [f(j) g(:,j) diff(:,:,j)] = funObj(x + mu*i*e_j,varargin{:});
    end
    f = mean(real(f));
    g = mean(real(g),2);
    H = mean(real(diff),3);
    T = imag(diff)/mu;
else % Use finite differencing
    mu = 2*sqrt(1e-12)*(1+norm(x));
    
    [f,g,H] = funObj(x,varargin{:});
    diff = zeros(p,p,p);
    for j = 1:p
        e_j = zeros(p,1);
        e_j(j) = 1;
        [junk1 junk2 diff(:,:,j)] = funObj(x + mu*e_j,varargin{:});
    end
    T = (diff-repmat(H,[1 1 p]))/mu;
end

