 function [trajs] = traj_from_assignment_3D(assignment, Min_length_traj)

%% check if multiple processors can be used
    Version = version ;
    numero  = str2num(Version(13:16));
    if (numero <= 2013 )
        if ( matlabpool('size') == 0 )
            myCluster = parcluster('local');
            matlabpool(myCluster, myCluster.NumWorkers);
        end
    else
        if( isempty(gcp('nocreate')) )
            myCluster = parcluster('local');
            parpool(myCluster, myCluster.NumWorkers);
        end
    end


trajs_set       = [];
indice          = 1;
indice_global   = 1;
n               = length(assignment);

%% criterion on free assignement
[assignment.real_sum]=deal( 0);
parfor i = 1 : n
    assignment(i).real_sum = sum(assignment(i).real_assignment);
end



%%   progress between global frames 
while(indice_global <= n - 1 )
       
    
    %%  if there is still something to be assign   
    while(assignment(indice_global).real_sum ~= 0)
        
        if ( isempty( assignment(indice_global).x_all)  )
            break;
        else
            indice_global_local = indice_global;
            II = find(assignment(indice_global).real_assignment ~=0);
        
        
            %%
            kkk = II(1);
            lll = assignment(indice_global).real_assignment(kkk); 
            trajs_set = [trajs_set; indice, assignment(indice_global_local).x_all(kkk),assignment(indice_global_local).y_all(kkk), ...
                        assignment(indice_global_local).z_all(kkk),assignment(indice_global_local).t_all(kkk) ];
            assignment(indice_global_local).real_assignment(kkk) = 0;
            assignment(indice_global_local).real_sum = sum(assignment(indice_global_local).real_assignment);
        
            %% follow assignent links
            while (1)
        
               % fprintf('%i\t %i\n',indice_global_local, indice_global );
                indice_global_local = indice_global_local + 1;
                if ( isempty( assignment(indice_global_local).x_all)  )
                    break;
                else
                
                    trajs_set = [trajs_set; indice, assignment(indice_global_local).x_all(lll),assignment(indice_global_local).y_all(lll), ...
                        assignment(indice_global_local).z_all(lll),assignment(indice_global_local).t_all(lll) ];
                    kkk   = lll;
                    lll   = assignment(indice_global_local).real_assignment(kkk);
                    if ( (lll ==0) || (indice_global_local> n - 1) )
                        break; 
                    else
                        assignment(indice_global_local).real_assignment(kkk) = 0;
                        assignment(indice_global_local).real_sum = sum(assignment(indice_global_local).real_assignment);
                    end
                
                end
            
            end
            indice = indice + 1;
        end
        
    end
    indice_global =  indice_global + 1;
    
    
end




nb = unique(trajs_set(:,1));

trajs = [];
for k = 1 : length(nb)
    
    II = trajs_set(:,1) == nb(k) ;
    if ( sum(II) >= Min_length_traj)
        trajs = [trajs; trajs_set(II,:)];
    end
    
    
end








