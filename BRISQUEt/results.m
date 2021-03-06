clear all
close all
clc

addpath('./misc_functions/')
path = './dist_levels/';


%% get all features (run to extract features) commented for now, because features already extracted
% labels = [];
% feats = [];
% for dist_level = 1:31
%     for num = 1:100
%         img_name = sprintf([path,'/%d/','meme_%d.jpg'],dist_level, num);
%         disp(img_name);
%         img = double(rgb2gray(imread(img_name)));
%         feat = brisque_feature(img);
%         feats = [feats; feat];
%         labels = [labels;dist_level];
%     end
% end
% image_id = repmat(1:100, [1, 31]);
% image_id = image_id';

%% load saved features and labels
load('feats_label_pair.mat')

%% randomly choosing 80 contents for traingin and rest for testing 
train_contents = datasample(1:100,80,'Replace',false);
train_id = ismember(image_id, train_contents);
test_id = ~train_id;

train_feats = feats(train_id, :);
train_labels = labels(train_id, :);

test_feats = feats(test_id, :);
test_labels = labels(test_id, :);


%% standard scaling of features

mu_class = mean(train_feats);
std_class = std(train_feats);

% atrain = repmat(a_class,[size(trainData,1) 1]);     atest = repmat(a_class,[size(testData,1) 1]);
% btrain = repmat(b_class,[size(trainData,1) 1]);     btest = repmat(b_class,[size(testData,1) 1]);

mutrain = repmat(mu_class,[size(train_feats,1) 1]);     mutest = repmat(mu_class,[size(test_feats,1) 1]);
stdtrain = repmat(std_class,[size(train_feats,1) 1]);     stdtest = repmat(std_class,[size(test_feats,1) 1]);

% dataTrain = atrain.*trainData+btrain;               dataTest = atest.*testData+btest;
% valueTrain = trainValue;                            valueTest = testValue;


dataTrain = (train_feats - mutrain)./stdtrain;               dataTest = (test_feats - mutest)./stdtest;
valueTrain = train_labels;                            valueTest = test_labels;

%% svm params
cv = 0;
C = 128;
g = 0.01;

bestC = C;
bestg = g;

%% uncommment below code to run cross validation provided cv = 1
% if cv
%     folds = 5;
%     [C,gamma] = meshgrid(4:8, -6:-2);
%     %
%     % %# grid search, and cross-validation
%     cv_acc = zeros(numel(C),1);
%     for jj=1:numel(C)
%         cv_acc(jj) = svmtrain(valueTrain, dataTrain, ...
%             sprintf('-s 4 -c %f -g %f -v %d -q',2^C(jj), 2^gamma(jj), folds));
%     end
%     
%     %# pair (C,gamma) with best accuracy
%     [~,idx] = min(cv_acc);
%     %# now you can train you model using best_C and best_gamma
%     bestC = 2^C(idx);
%     bestg = 2^gamma(idx);
% else
%     bestC = C;
%     bestg = g;
% end

%% train
cmd = ['-s 4 -c ' num2str(bestC) ' -g ' num2str(bestg) ' -q'];
model_reg = svmtrain(valueTrain, dataTrain, cmd);



%% test
[prediction, ~,~] = svmpredict(zeros(size(valueTest)),dataTest,model_reg);
acc = corr(prediction,valueTest,'Type','Spearman');
figure, scatter(valueTest, prediction);
xlabel('actual compression level')
ylabel('predicted compression level') %% can be negative since it is a regression problem