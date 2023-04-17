%%
clear all;
close all;
original = imread("C:\Users\Marta\Desktop\aom_projekt\program\BUS\original\000002.png");
mask = imread("C:\Users\Marta\Desktop\aom_projekt\program\BUS\GT\000002.png");

%%
%normalny
normal = imread("C:\Users\Marta\Desktop\aom_projekt\program\Dataset_BUSI_with_GT\normal\normal (133).png");

%łagodny
benign = imread("C:\Users\Marta\Desktop\aom_projekt\program\Dataset_BUSI_with_GT\benign\benign (1).png");
mask_b = imread("C:\Users\Marta\Desktop\aom_projekt\program\Dataset_BUSI_with_GT\benign\benign (1)_mask.png");

%złośliwy
malignant = imread("C:\Users\Marta\Desktop\aom_projekt\program\Dataset_BUSI_with_GT\malignant\malignant (1).png");
mask_m = imread("C:\Users\Marta\Desktop\aom_projekt\program\Dataset_BUSI_with_GT\malignant\malignant (1)_mask.png");
%%
figure()
imshow(original);

figure()
imshow(mask);

%%
figure(1)
imshow(normal)

figure(2)
imshow(benign)
figure(3)
imshow(mask_b)

figure(4)
imshow(malignant)
figure(5)
imshow(mask_m)


%% GLCM
%graycomatrix
glcm = graycomatrix(original,'Offset',[2 0; 0 2]);

offsets = [0 1; 1 0;-1 0;-1 -1];
[glcms,SI] = graycomatrix(original,'Offset',offsets);

GLCM = rescale(SI);
figure()
imshow(GLCM);
 title('glcm');
%graycoprops
stats = graycoprops(glcm,{'contrast','homogeneity'}); %kontrast i jednorodność


%% regionprops
punkt = regionprops(im2bw(mask), 'Area', 'Centroid' , 'MajorAxisLength', 'MinorAxisLength');
centroids = cat(1,punkt.Centroid);
figure()
imshow(mask);
hold on
plot(centroids(:,1),centroids(:,2),'b*')
hold off

%tworzenie obrazu na podstawie punktu startowego
punkty = zeros(size(original));
punkty(round(centroids(:,2)),round(centroids(:,1))) = 1;
imshow(punkty);
punkty(round(centroids(:,2)+5),round(centroids(:,1))) = 1;
punkty(round(centroids(:,2)-5),round(centroids(:,1))) = 1;
punkty(round(centroids(:,2)),round(centroids(:,1)+5)) = 1;
punkty(round(centroids(:,2)),round(centroids(:,1)-5)) = 1;
figure()
imshow(punkty);

%znalezienie indeksów oraz współrzednych punktów
indeksy = find(punkty)
[y,x] = find(punkty)



%rozrost punktów
bw_original = im2double(original);
r1 = regiongrowing(~(bw_original),y(1),x(1),0.2);
r2 = regiongrowing(~(bw_original),y(2),x(2),0.2);
r3 = regiongrowing(~(bw_original),y(3),x(3),0.2);
r4 = regiongrowing(~(bw_original),y(4),x(4),0.2);
r5 = regiongrowing(~(bw_original),y(4),x(4),0.2);

r = r1+r2+r3+r4+r5;
figure()
imshow(r);


% wypelnienie i dalatacja - nie są potrzebne
% F=imfill(r,'holes');
% D = imdilate(F, [0 1 0; 1 1 1; 0 1 0]);
% D = imdilate(D, [0 1 0; 1 1 1; 0 1 0]);
% D = imdilate(D, [0 1 0; 1 1 1; 0 1 0]);
% D = imdilate(D, [1 1 1; 1 1 1; 1 1 1]);
% figure()
% imshow(D)
%%
mask_glcm = activecontour(GLCM, r, 50);
figure()
imshow(GLCM)
% title('glcm + active contour');
hold on;
kontur1 = visboundaries(mask_glcm,'Color','r'); %nałozenie konturu zaznaczającego zmiane



%% non local means
noisyImage = imnoise(original,'gaussian',0,0.0015);
[filteredImage,estDoS] = imnlmfilt(original, 'DegreeOfSmoothing',10);
figure()
imshow(filteredImage)
title('obraz po filtracji non local means');


% mask_nlm = activecontour(filteredImage, mask, 200, 'chan-Vese'); 

mask_nlm = activecontour(filteredImage, r, 50);
figure()
imshow(filteredImage)
% title('glcm + active contour');
hold on;
kontur2 = visboundaries(mask_nlm,'Color','r'); %nałozenie konturu zaznaczającego zmiane
%% Podobieństwo
%---glcm---------
%współczynnik podobieństwa Sørensena-Dice'a 
mask=logical(mask);
sorensen_glcm = dice(mask,mask_glcm)


% współczynnik podobieństwa Jaccard'a
jaccard_glcm = jaccard(mask, mask_glcm)

figure()
imshowpair(mask,mask_glcm)
title('Podobieństwo maski eksperckiej i maski glcm + aktywny konur')

%--------nlm + active counter--------
% współczynnik podobieństwa Sørensena-Dice'a 
sorensen_nlm = dice(mask, mask_nlm)

% współczynnik podobieństwa Jaccard'a
jaccard_nlm = jaccard(mask, mask_nlm)

figure()
imshowpair(mask, mask_nlm)
title('Podobieństwo maski eksperckiej i maski nlm + aktywny konur')
