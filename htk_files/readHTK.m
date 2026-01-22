function [data, header] = readHTK(filename)

    fid = fopen(filename, 'rb', 'b'); % 'b' = big-endian (HTK usa big-endian)
    if fid == -1
        error('No se pudo abrir el archivo HTK');
    end

    % Leer header
    header.nSamples   = fread(fid, 1, 'int32');
    header.sampPeriod = fread(fid, 1, 'int32');
    header.sampSize   = fread(fid, 1, 'int16');
    header.parmKind   = fread(fid, 1, 'int16');

    % Dimensión de cada frame
    nFeatures = header.sampSize / 4; % float32 → 4 bytes

    % Leer datos
    data = fread(fid, [nFeatures, header.nSamples], 'float32')';
    
    fclose(fid);
end
