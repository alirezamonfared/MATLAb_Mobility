% Solving Sensor Localization System

function Y = ESDP(PP,m,n,r,nf,degree)
% PP: 2xn matrix representing all point on 2D
% n : the number of total sensor points
% m : the number of anchor points; first m columns of PP
% r : the radio range
% nf: noisy factor
% degree: the limit on the number of edges connected to any sensor point
% Developed by Zizhuo Wang, Song Zheng and Yinyu Ye for Demonstration;
% see paper http://www.stanford.edu/~yyye/relaxationsdp6.pdf

clc
clear K;
tt = cputime;
format long;
anchor=PP(:,1:m);
X_a=PP(:,m+1:n);
n=n-m;
pars.eps=1.e-3;
clear PP;

% X_a is the true location of the sensos
% anchor is the location of the anchors
%% The first timing part

tic
D_a = sparse(n,n);
number = 0;
label = sparse(n,n);
 
for i = 1:1:n-1
    flag = 0 ;
    for j = i+1:1:n
            d = norm(X_a(:,i)-X_a(:,j),2);
            if d < r && flag<degree
                flag =flag+1;
                D_a(i,j) = d^2*max(0,1+nf*randn(1));
                number=number+1;
                label(i,j) = number;
            end        
    end
end



% the known distance between anchors and sensors

label = label+label';
D_as = sparse(m,n);
number_as=0;
label_as=sparse(m,n);

for i = 1:1:m;
    for j = 1:1:n
        d = norm(anchor(:,i)-X_a(:,j),2);
        if d < r
            D_as(i,j) = d^2*max(0,1+nf*randn(1));
            number_as = number_as+1;
            label_as(i,j) = number_as;
        end
    end
end
t1 = toc

% the second part
tic 
 
A = sparse(1,19*number+3*number_as);
b = zeros(1,1);
counting = 1;


for i = 1:1:n-1
    for j = i+1:1:n
        if label(i,j)>0
            ii=counting;
            jj=16*label(i,j)+3*number+3*number_as;
            A(ii:ii+4,jj-15:jj)=...
                sparse([1 zeros(1,15);0 1 zeros(1,14);...
                        zeros(1,5) 1 zeros(1,10);zeros(1,10) 1 -1 0 0 -1 1;...
                                                 zeros(1,10) 1 -1 0 0 -1 1]);
            jj=3*label(i,j);
            A(ii+3:ii+4,jj-2:jj)=sparse([-1 1 0;1 0 -1]);
            b(ii:ii+4,1)=[1;0;1;D_a(i,j);D_a(i,j)];
            counting = counting+5;
        end
    end
end
t2=toc
clear D_a;

% the third part
tic
for i = 1:1:n
    for j = 1:1:n
        if label(i,j)>0
            for k = 1:1:m
                if label_as(k,i)>0
                    ii=counting;
                    if j<i
                        jj=16*label(i,j)+3*number+3*number_as;
                        A(ii:ii+1,jj-13:jj-5)=...
                            sparse([-2*anchor(1,k) 0 0 0 -2*anchor(2,k) 0 0 0 1;...
                                    -2*anchor(1,k) 0 0 0 -2*anchor(2,k) 0 0 0 1]);
                        jj=3*number+3*label_as(k,i);
                        A(ii:ii+1,jj-2:jj)=sparse([-1 1 0;1 0 -1]);
                    end
                    
                    if j>i
                        jj=16*label(i,j)+3*number+3*number_as;
                        A(ii:ii+1,jj-13:jj)=...
                         sparse([0 -2*anchor(1,k) zeros(1,3) -2*anchor(2,k) zeros(1,7) 1;...
                         -2*anchor(1,k) zeros(1,3) -2*anchor(2,k) zeros(1,3) 1 zeros(1,5)]);  
                        jj=3*number+3*label_as(k,i);
                        A(ii:ii+1,jj-2:jj)=sparse([-1 1 0;1 0 -1]);
                    end
                    b(ii:ii+1,1)=(D_as(k,i)-anchor(1,k)^2-anchor(2,k)^2)*ones(2,1);
                    counting = counting+2;
                end
            end
            break;
        end
    end
end
t3=toc
clear D_as label_as;
% Next we will set up the linking constraints

tic

for i = 1:1:n
    flag = 0;
    
    for j = 1:1:n
        
        if label(i,j)>0 && flag == 0
            flag = 1;
            f = j;
            continue;
        end
        
        if label(i,j)>0 && flag == 1
            ii=counting;
            if f<i
                jj=16*label(i,f)+3*number+3*number_as;
                A(ii:ii+2,jj-13:jj-5)=sparse([zeros(1,8) 1;...
                                              zeros(1,4) 1 zeros(1,4);...
                                              1 zeros(1,8)]);
            else
                jj=16*label(i,f)+3*number+3*number_as;
                A(ii:ii+2,jj-12:jj)=sparse([zeros(1,12) 1;...
                                            zeros(1,4) 1 zeros(1,8);...
                                            1 zeros(1,12)]);
            end
            
            if j<i
                jj=16*label(i,j)+3*number+3*number_as;
                A(ii:ii+2,jj-13:jj-5)=sparse([zeros(1,8) -1;...
                                              zeros(1,4) -1 zeros(1,4);...
                                              -1 zeros(1,8)]);
            else
                jj=16*label(i,j)+3*number+3*number_as;
                A(ii:ii+2,jj-12:jj)=sparse([zeros(1,12) -1;...
                                            zeros(1,4) -1 zeros(1,8);...
                                            -1 zeros(1,12)]);
            end
            b(ii:ii+2,1)=zeros(3,1);
            counting = counting+3;            
        end
    end
end
t4=toc
tic
mequal = counting-1

c = sparse(zeros(19*number+3*number_as,1));

for i = 1:1:number+number_as
    c(3*i-2) = 1;
end


% run sedumi to solve the SDP problem

clear K
K.l = 3*number+3*number_as;
K.s = 4*ones(1,number);
t5=toc
pars.stepdif=0;
tic
x= sedumi(A,b,c,K,pars);
t6=toc
% Here we will give the Y and mark the elements that are determined by our 
% new algorithm

Y = zeros(n+2,n+2);
Y(1,1) = 1;
Y(1,2) = 0;
Y(2,1) = 0;
Y(2,2) = 1;

for i = 1:1:n
    for j = 1:1:n
        if label(i,j)>0
            jj=16*label(i,j)+3*number+3*number_as;
            if j>i
                Y(1:2,i+2) = [x(jj-12);x(jj-8)];
                Y(i+2,1:2) = [x(jj-3) x(jj-2)];
                Y(i+2,i+2) = x(jj);
            else
                Y(1:2,i+2) = [x(jj-13);x(jj-9)];
                Y(i+2,1:2) = [x(jj-7) x(jj-6)];
                Y(i+2,i+2) = x(jj-5);
            end
            
        end
    end
end


for i = 1:1:n
    for j = i+1:1:n
        if label(i,j)>0
            jj=16*label(i,j)+3*number+3*number_as;
            Y(i+2,j+2) = x(jj-4);
            Y(j+2,i+2) = x(jj-1);
        end
    end
end

figure(1)

% Draw the locations of the anchors and the sensors 
screensize = [0,0,1,1];
for i = 1:1:m
    plot(anchor(1,i),anchor(2,i),'d');
    hold on;
end

for i = 1:1:n
    plot(X_a(1,i),X_a(2,i),'og');
    hold on;
end                
               
Z = Y(3:i+2,3:i+2)-Y(1:2,3:i+2)'*Y(1:2,3:i+2);
z = diag(Z);

% calculate the deviation
error = zeros(n,1);

for i = 1:1:n
    error(i) = norm(X_a(:,i)-Y(i+2,1:2)');
end
hold on;

% draw the position calculated by my program
for i = 1:n
    hold on;
    plot(Y(i+2,1),Y(i+2,2),'*r');
    hold on;
    line([X_a(1,i),Y(i+2,1)],[X_a(2,i),Y(i+2,2)]);
end

figure(2)
for i = 1:n
    hold on;
    plot(i,error(i),'bs');
end