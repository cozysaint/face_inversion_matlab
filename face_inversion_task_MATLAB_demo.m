% face inversion task MATLAB demo
% 2023-2 cog psych lab

sID = input('enter participant number:', 's');

Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');

grey = [128; 128; 128];

ptrScreen = max(Screen('Screens'));
[w, rect_screen] = Screen('OpenWindow',ptrScreen, grey);
HideCursor;

[horizontal_center, certical_center] = RectCenter(rect_screen);
cd('stimuli');

face_dir = Shuffle(dir('f*.jpg'));
scene_dir = Shuffle(dir('s*.jpg'));
Nimage = 10;

% loading images
for i = 1:Nimage

    % training images
    face_matrix = double(imread(face_dir(i).name));
    training_face_texture(i) = Screen('MakeTexture', w, face_matrix);

    face_matrix = double(imread(face_dir(i + Nimage).name));
    training_face_inverted_texture(i) = Screen('MakeTexture', w, flipud(face_matrix));

    scene_matrix = double(imread(scene_dir(i).name));
    training_scene_texture(i) = Screen('MakeTexture', w, scene_matrix);

    scene_matrix = double(imread(scene_dir(i + Nimage).name));
    training_scene_inverted_texture(i) = Screen('MakeTexture', w, flipud(scene_matrix));

    % test images
    face_matrix = double(imread(face_dir(i + Nimage*2).name));
    test_face_texture(i) = Screen('MakeTexture', w, face_matrix);

    face_matrix = double(imread(face_dir(i + Nimage*3).name));
    test_face_inverted_texture(i) = Screen('MakeTexture', w, flipud(face_matrix));

    scene_matrix = double(imread(scene_dir(i + Nimage*2).name));
    test_scene_texture(i) = Screen('MakeTexture', w, scene_matrix);

    scene_matrix = double(imread(scene_dir(i + Nimage*3).name));
    test_scene_inverted_texture(i) = Screen('MakeTexture', w, flipud(scene_matrix));

end

image_height= size(face_matrix, 1);
image_width= size(face_matrix, 2);

% image size

left_edge = horizontal_center - image_width/2;
right_edge = horizontal_center + image_width/2;
top_edge = vertical_center - image_height/2;
bottom_edge = vertical_center + image_height/2;
image_rect = [left_edge; topedge; right_edge; bottom_edge];

% image location

distance_from_center = 250;
left_image = [horizontal_center = distance_from_center - image_width/2; vertical_center - image_hight/2; ...
    horizontal_center - distance_from_center + image_width/2; vertical_center + image_height/2];
right_image = [horizontal_center + distance_from_center - image_width/2;] vertical_center - image_hight/2; ...
    horizontal_center + distance_from_center + image_width/2; vertical_center + image_height/2];

% image time

image_time = 0.5;
wait_time = 0.5;

blocks = {'face','inverted_face', 'scene', 'inverted_scene'};
block = blocks(randperm(Nblocks));

reponses = cell(Nimage, Nblocks);
correct_answers = Shuffle{'left';'right';'left';'right';'left';'right';'left';'right';'left';'right';}
correct_answers = cat(2, Shuffle(correct_answers), Shuffle(correct_answers), Shuffle(correct_answers), Shuffle(correct_answers));

% 입력키
left_key = KbName('LeftArrow');
left_key = KbName('RightArrow');
esc_key = KbName('ESCAPE');

for block = 1:Nblocks
   
    % 4가지의 블락
    if strcmp(blocks(block), 'face')
        training_texture = training_face_texture;
        test_texture = test_face_texture;
    elseif strcmp(blocks(block), 'inverted_face')
        training_texture = training_face_inverted_texture;
        test_texture = test_face_inverted_texture;
    elseif strcmp(blocks(block), 'scene')
        training_texture = training_scene_texture;
        test_texture = test_scene_texture;    
    elseif strcmp(blocks(block), 'invereted_scene')
        training_texture = training_inverted_scene_texture;
        test_texture = test_inverted_scene_texture;   
    end

    for i = 1:Nimage % 1부터 Nimage까지 보여준다
        Screen('DrawTexture', w, training_texture(i), [], image_rect); % 보이지 않는 화면에 그리을 그려놓는다
        Screen('Flip', w); % 화면을 뒤집는다

        % 제시시간 부여
        start_time = GetSecs;
        while GetSecs - start_time < image_time
        end

        % 다시 안 보이게 화면을 뒤집는다
        Screen('Flip', w);

        % 대기시간 부여
        start_time = GetSecs;
        while GetSecs - start_time < wait_time
        end

    end

    % test phase
    training_texture = Shuffle(training_texture); % 이전에 사용했던 순서대로 나오기 때문에 섞어주어야 함

    for i = 1:Nimage

        if strcmp(correct_answers{i, block}, 'right')
            Screen('DrawTexture', w, test_texture(i), [], left_image);
            Screen('DrawTexture', w, training_texture(i), [], right_image);
        elseif strcmp(correct_answers{i, block}, 'left')
            Screen('DrawTexture', w, test_texture(i), [], right_image);
            Screen('DrawTexture', w, training_texture(i), [], left_image);
        end        
        
        % image 보여주기
        Screen('Flip', w);
        
        key_press = 0;
        while ~key_press
            [key_press, key_time, which_key] = KbCheck(-1);
            if key_press
                if which_key(left_key)
                    responses{i, block} = 'left';
                elseif which_key{right_key} 
                    reponses{i, block} = 'right';
                elseif which_key(esc_key)
                    ShowCursor;
                    Screen('CloseAll');
                else
                    key_press = 0;
                end
            end

        end
  
    end

end

fileName = strcat(sID, '_face_inversion_result.mat');
save(fileName, 'correct_answers', 'responses', 'blocks');
Screen('CloseAll');
ShowCursor;






