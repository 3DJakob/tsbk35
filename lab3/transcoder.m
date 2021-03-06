function [psnr, bpp]=transcoder(filename, blocksize, qy, qc, scale, usejpgrate, transformMethod, quantization)

% This is a very simple transform coder and decoder. Copy it to your directory
% and edit it to suit your needs.
% You probably want to supply the image and coding parameters as
% arguments to the function instead of having them hardcoded.


% Read an image
% im=double(imread('image1.png'))/255;
im=double(imread(filename))/255;

% What blocksize do we want?
% blocksize = [8 8];

% Quantization steps for luminance and chrominance
% qy = 0.1;
% qc = 0.1;

% Change colourspace 
imy=rgb2ycbcr(im);

bits=0;


% Somewhere to put the decoded image
imyr=zeros(size(im));


% First we code the luminance component
% Here comes the coding part

if transformMethod == "bdct"
    tmp = bdct(imy(:,:,1), blocksize); % DCT
else
    tmp = bdwht(imy(:,:,1), blocksize); % bdwht
end

if quantization == "uniform"
   tmp = bquant(tmp, qy);             % Simple quantization
else
    QL=repmat(1:blocksize(1), blocksize(1), 1);
    QL= (QL+QL'-9) /blocksize(1);
    k1=0.1; k2=0.3;
    k1=qy;
    k2=qc;
    Q2=k1* (1+k2*QL);
    tmp = bquant(tmp, Q2);
end
p = ihist(tmp(:));                 % Only one huffman code

if usejpgrate
    bits = bits + sum(jpgrate(tmp, blocksize));
else
     bits = bits + huffman(p); % Add the contribution from each component
end

% Here comes the decoding part
if quantization == "uniform"
   tmp = brec(tmp, qy);               % Reconstruction
else
   tmp = brec(tmp, Q2);
end

if transformMethod == "bdct"
    imyr(:,:,1) = ibdct(tmp, blocksize, [512 768]);  % Inverse DCT
else 
    imyr(:,:,1) = ibdwht(tmp, blocksize, [512 768]);  % Inverse bdwht
end



% Next we code the chrominance components
for c=2:3                          % Loop over the two chrominance components
  % Here comes the coding part

  tmp = imy(:,:,c);
  tmp = imresize(tmp, scale);
  smallerSize = size(tmp);
  

  % If you're using chrominance subsampling, it should be done
  % here, before the transform.

  if transformMethod == "bdct"
    tmp = bdct(tmp, blocksize);      % DCT
  else 
    tmp = bdwht(tmp, blocksize);      % bdwht
  end

  if quantization == "uniform"
    tmp = bquant(tmp, qc);           % Simple quantization
  else
    QL=repmat(1:blocksize(1), blocksize(1), 1);
    QL= (QL+QL'-9) /blocksize(1);
    k1=0.1; k2=0.3;
    k1=qy;
    k2=qc;
    Q2=k1* (1+k2*QL);
    tmp = bquant(tmp, Q2);
  end
  p = ihist(tmp(:));               % Only one huffman code
                                   % each component  
  if usejpgrate
    bits = bits + sum(jpgrate(tmp, blocksize));
  else
%      blsize = blocksize(1,1) * blocksize(1,1);
     for i = 1:size(tmp, 2)
%          tmp(:,i)
         p = ihist(tmp(:, i));
         bits = bits + huffman(p);
     end
%      bits = bits + huffman(p); % Add the contribution from
  end
			
  % Here comes the decoding part
  if quantization == "uniform"
    tmp = brec(tmp, qc);            % Reconstruction
  else
    tmp = brec(tmp, Q2);
  end

  if transformMethod == "bdct"
      tmp = ibdct(tmp, blocksize, smallerSize);  % Inverse DCT
  else 
      tmp = ibdwht(tmp, blocksize, smallerSize);  % Inverse bdwht
  end
  

  % If you're using chrominance subsampling, this is where the
  % signal should be upsampled, after the inverse transform.

  imyr(:,:,c) = imresize(tmp, 1/scale);
  
end

% Display total number of bits and bits per pixel
% bits;
bpp = bits/(size(im,1)*size(im,2));

% Revert to RGB colour space again.
imr=ycbcr2rgb(imyr);

% Measure distortion and PSNR
dist = mean((im(:)-imr(:)).^2);
psnr = 10*log10(1/dist);

% Display the original image
% figure, imshow(im)
% title('Original image')

%Display the coded and decoded image
figure, imshow(imr);
title(sprintf('Decoded image, %5.2f bits/pixel, PSNR %5.2f dB', bpp, psnr))

