% Script para cargar hmmdefs y graficar PDFs Gaussianas
folder_name = 'plots';
filenames = {'models_3_states/Group_01/hmm6/hmmdefs',
    'models_3_states/Group_02/hmm6/hmmdefs',
    'models_3_states/Group_03/hmm6/hmmdefs',
    'models_3_states/Group_04/hmm6/hmmdefs',
    'models_3_states/Group_05/hmm6/hmmdefs',
    'models_3_states/Group_06/hmm6/hmmdefs',
    'models_3_states/Group_07/hmm6/hmmdefs',
    'models_3_states/Group_08/hmm6/hmmdefs',
    'models_3_states/Group_09/hmm6/hmmdefs',
    'models_3_states/Group_10/hmm6/hmmdefs'};
nombres_dimensiones = {'ROM', 'Biceps EMG', 'Triceps EMG', 'Speed', 'Acceleration', 'Jerk'};

if ~exist(folder_name, 'dir')
    mkdir(folder_name);
    fprintf('Carpeta "%s" creada con éxito.\n', folder_name);
end

for k = 1:length(filenames)
    filename = filenames{k}
    fid = fopen(filename, 'r');
    
    if fid == -1
        error('No se pudo abrir el archivo hmmdefs. Verifica la ruta.');
    end
    
    % Estructura para almacenar los datos
    modelos = struct();
    model_names = {'SegundoPRIMARIA', 'SegundoESO', 'QuintoPRIMARIA'};
    current_model = '';
    
    % Lectura del archivo línea por línea
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        
        % Identificar el nombre del modelo
        if startsWith(line, '~h')
            for i = 1:length(model_names)
                if contains(line, model_names{i})
                    current_model = model_names{i};
                    break;
                end
            end
        end
        
        % Extraer Medias
        if startsWith(line, '<MEAN>') && ~isempty(current_model)
            val_line = fgetl(fid);
            modelos.(current_model).mean = str2num(val_line);
        end
        
        % Extraer Varianzas
        if startsWith(line, '<VARIANCE>') && ~isempty(current_model)
            val_line = fgetl(fid);
            modelos.(current_model).var = str2num(val_line);
        end
    end
    fclose(fid);
    
    % --- Generación de Gráficos ---
    fig = figure('Name', 'Analysis of Gaussian Emissions (HTK)', 'Color', 'w', 'Visible', 'off');
    tlo = tiledlayout(2, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
    colores = {'r', 'b', 'g'};
    
    p = []; 
    
    for dim = 1:6
        nexttile; hold on;
        title(nombres_dimensiones{dim}, 'FontSize', 10);
        xlabel('Value'); ylabel('Density');
        
        for i = 1:length(model_names)
            name = model_names{i};
            if isfield(modelos, name)
                mu = modelos.(name).mean(dim);
                sigma = sqrt(modelos.(name).var(dim));
                
                x = linspace(mu - 4*sigma, mu + 4*sigma, 500); % Un poco más de margen
                y = (1/(sigma * sqrt(2*pi))) * exp(-0.5 * ((x-mu)/sigma).^2);
                
                h = plot(x, y, 'Color', colores{i}, 'LineWidth', 1.5, 'DisplayName', name);
                
                % Guardamos los handles de la primera dimensión para la leyenda
                if dim == 1, p(i) = h; end
            end
        end
        grid on;
    end

    % Creamos la leyenda global usando los handles guardados
    lgd = legend(p, model_names, 'Orientation', 'horizontal');
    lgd.Layout.Tile = 'south'; % Esto la coloca fuera de las gráficas, abajo al centro

    % Título global del grupo
    sgtitle(['Group ' num2str(k, '%02d')], 'FontSize', 14, 'FontWeight', 'bold');

    save_path = fullfile(folder_name, ['plot_Group_' num2str(k, '%02d') '.png']);
    saveas(fig, save_path);

    fprintf('Saved: %s\n', save_path);
end

fprintf('Process completed. Please check the folder "%s".\n', folder_name);