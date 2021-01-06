function [subjectID, stop] = collectinfo()
subjectID = input('Numero Partecipante (0 per terminare): ');
stop = false;

if subjectID == 0
    disp('Esperimento terminato!!')
    stop = true;
    return
else
    folderID = sprintf("calibration_data/S%d", subjectID);
    if exist(folderID, 'dir')
        overwrite = input('La cartella esiste già. Vuoi sovrascrivere? (1 = si, 0 = no): ');
        if overwrite == 1
            rmdir(folderID, 's')
            mkdir(folderID)
            fprintf("Partecipante %d sovrascritto!", subjectID)
        elseif overwrite == 0
            disp('Esperimento terminato!!')
            stop = true;
            return
        end
    else
        mkdir(folderID)
        fprintf("Cartella per partecipante %d creata!", subjectID)
    end
end
player = audioplayer(sin(1:0.1:1000), 44100); play(player)
player = audioplayer(sin(1:0.1:1000), 44100); play(player)
pause(2)