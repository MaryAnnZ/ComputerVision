close all
clc

C = BuildVocabulary('train', 50);
[training, group] = BuildKNN('train', C);
confmat = ClassifyImages('owntest', C, training, group);

correct = sum(diag(confmat)); % correct classifications are in diagonal
disp(['Eval: ' ,num2str(correct) ,' of ', num2str(size(confmat, 1)),' points have been classified correctly.']);
disp(['This is a positive rate of ', num2str(correct / size(confmat, 1) *100),'%.']);
disp(confmat);