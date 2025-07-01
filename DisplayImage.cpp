#include <stdio.h>
#include <opencv2/opencv.hpp>
using namespace cv;

#define FLOAT_TO_INT(x) ((x) >= 0 ? (int)((x) + 0.5) : (int)((x) - 0.5))

extern "C" double valorRGBlineal(double RGBcomprimido);
extern "C" double valorYcomprimido(double valorYlineal);
extern "C" int procesarImagen(const uchar *pSource, uchar *pDestination, int nRows, int nCols, int channels);

int main(int argc, char **argv)
{
	int resultado;
	uchar *p;
	int channels;
	int nRows;
	int nCols;

	if (argc != 2)
	{
		printf("Uso:  testopencv <imagen>\n");
		return (-1);
	}
	Mat imageOriginal;
	imageOriginal = imread(argv[1], IMREAD_COLOR);
	if (!imageOriginal.data)
	{
		printf("Sin datos de imagen... \n");
		return (-1);
	}
	namedWindow("Original", WINDOW_AUTOSIZE);
	imshow("Original", imageOriginal);

	channels = imageOriginal.channels();
	nRows = imageOriginal.rows;
	nCols = imageOriginal.cols;
	size_t buffer_size = nRows * nCols * channels;

	Mat imageDestination(nRows, nCols, imageOriginal.type());
	const unsigned char *pSource = imageOriginal.data;
	unsigned char *pDestination = imageDestination.data;

	printf("CTRL+C para finalizar\n\n");
	printf("Filas: %d\n", nRows);
	printf("Columnas: %d\n", nCols);
	printf("Canales: %d\n", channels);
	CV_Assert(imageOriginal.depth() == CV_8U);

	resultado = procesarImagen(pSource, pDestination, nRows, nCols, channels);

	namedWindow("Grayscale", WINDOW_AUTOSIZE);
	imshow("Grayscale", imageDestination);

	waitKey(0);
	delete[] pDestination;
	return (0);
}
