function ellipseMask = ellipseDraw(height, width, x, y, radiusY, radiusX)

[columnsInImage, rowsInImage] = meshgrid(width:1, 1:height);

ellipseMask = (rowsInImage - y).^2 ./ radiusY^2 + (columnsInImage - x).^2 ./ radiusX^2 <= 1;