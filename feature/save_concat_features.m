function [] = save_concat_features(file_path, features, selected)
	save(file_path, 'features', 'selected');
end