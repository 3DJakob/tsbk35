function [psnr, bpp]=transcoder(filename, blocksize, qy, qc, scale, usejpgrate, transformMethod)

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


tmp = bquant(tmp, qy);             % Simple quantization
p = ihist(tmp(:));                 % Only one huffman code
% bits = bits + huffman(p);          % Add the contribution from
                                   % each component

if usejpgrate
    bits = bits + sum(jpgrate(tmp, blocksize));
else
    bits = bits + huffman(p);
end
			
% Here comes the decoding part
tmp = brec(tmp, qy);               % Reconstruction

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

  tmp = bquant(tmp, qc);           % Simple quantization
  p = ihist(tmp(:));               % Only one huffman code
%   bits = bits + huffman(p);        % Add the contribution from
                                   % each component  

%   tmp = imresize(tmp, 0.5);

  if usejpgrate
    bits = bits + sum(jpgrate(tmp, blocksize));
  else
    bits = bits + huffman(p);
  end
			
  % Here comes the decoding part
  tmp = brec(tmp, qc);            % Reconstruction

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
% figure, imshow(imr);
% title(sprintf('Decoded image, %5.2f bits/pixel, PSNR %5.2f dB', bpp, psnr))

