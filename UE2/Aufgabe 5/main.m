close all
clc

C = BuildVocabulary('train', 50);
[training, group] = BuildKNN('train', C);
confmat = ClassifyImages('test', C, training, group);
