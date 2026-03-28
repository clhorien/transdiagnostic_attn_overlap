/usr/bin/matlab -nojvm >/path/to/logfile/motioncorrection.out <<EOF

%nii and hdr/img may have different parameters due to how spm reads the header matrix for nifti vs non-nifti
%old script uses linear interpolation
%naming output of .mat motion parameters is slightly different

path('/path/to/spm8',path);
use_old_flags=0;
use_middle_run=0;

basedir = ['path/to/data'];
study_list = ['sub1' ; 'sub2' ; 'sub3']; 


for i = 1:size(study_list,1)

    %may need to change the next two lines depending on your needs
    dir=basedir;
    filter_expression=sprintf('^%s.+.nii$',deblank(study_list(i,:)));

    parameter_dir=sprintf('%s/%s_realign/',dir,deblank(study_list(i,:)));

    f=spm_select('FPList',deblank(dir),filter_expression);

    if(use_middle_run)
	mid=ceil(size(f,1)/2);
	f=[ f(mid,:) ; f(1:(mid-1),:) ; f((mid+1):end,:) ]
    end

    if ~isempty(f)
        mrrc_motioncorrection_wrapper(f,use_old_flags,parameter_dir);
    end

end %for

quit

EOF













