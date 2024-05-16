% File names
input_filename = 'model.xyz';
output_filename = 'outputmodel.xyz';

% Read the entire file
file_content = fileread(input_filename);
lines = strsplit(file_content, '\n');

% Extract header information
header1 = lines{1};
header2 = lines{2};

% Modify header to include group information
header2 = strrep(header2, 'pos:R:3', 'pos:R:3:group:I:1');

% Read atom data
atom_data = lines(3:end-1);
num_atoms = length(atom_data);

% Extract y-coordinates and sort atoms by y
y_coords = zeros(num_atoms, 1);
atoms_sorted = cell(num_atoms, 1);

for i = 1:num_atoms
    parts = strsplit(atom_data{i});
    y_coords(i) = str2double(parts{3});
    atoms_sorted{i} = parts;
end

% Sort atoms by y-coordinate
[~, sort_idx] = sort(y_coords);
sorted_atom_data = atoms_sorted(sort_idx);

% Define the number of atoms per group based on specified ratios
ratios = [1/11, 2/11, 1/11, 1/11, 1/11, 1/11, 1/11, 1/11, 2/11]; % Ratios for each group
num_atoms_per_group = round(num_atoms * ratios);
actual_group_counts = zeros(1, 9);
group_assignments = zeros(num_atoms, 1);

% Assign atoms to groups based on the calculated number of atoms per group
current_atom_index = 1;
for group = 1:9
    for i = current_atom_index:min(current_atom_index + num_atoms_per_group(group) - 1, num_atoms)
        group_assignments(i) = group - 1;
    end
    current_atom_index = current_atom_index + num_atoms_per_group(group);
end

% Prepare the output
fid = fopen(output_filename, 'w');
fprintf(fid, '%s\n', header1);
fprintf(fid, '%s\n', header2);
for i = 1:num_atoms
    atom_line = sorted_atom_data{i};
    fprintf(fid, '%s\t%.6f\t%.6f\t%.6f\t%d\n', atom_line{1}, ...
            str2double(atom_line{2}), str2double(atom_line{3}), ...
            str2double(atom_line{4}), group_assignments(i));
end
fclose(fid);