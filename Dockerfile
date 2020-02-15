FROM nvidia/cuda:10.2-devel

ENV TARGET_CC="5.2"

RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential cmake unzip pkg-config \
	libjpeg-dev libpng-dev libtiff-dev \
	libavcodec-dev libavformat-dev libswscale-dev \
	libv4l-dev libxvidcore-dev libx264-dev \
	libgtk-3-dev libatlas-base-dev gfortran apt-utils \
	python3 python3-dev && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir /build-opencv

# replace these copies with direct pulls
COPY get-pip.py /build-opencv
COPY cudnn-10.2-linux-x64-v7.6.5.32.tgz /build-opencv
ADD opencv_contrib.zip /build-opencv

WORKDIR /build-opencv

# replace setup of opencv directory with git clone
# once we determine how to apt-get git in this docker environment
RUN mkdir opencv
WORKDIR /build-opencv/opencv
COPY opencv .
#RUN apt-get install -y --no-install-recommends git
#RUN git clone https://github.com/opencv/opencv.git

WORKDIR /build-opencv

# cannot directly pull this cudnn from Nvidia
RUN tar -zxvf cudnn-10.2-linux-x64-v7.6.5.32.tgz
RUN cd cuda && cp -P lib64/* /usr/local/cuda/lib64/ && \
    cp -P include/* /usr/local/cuda/include/
#RUN unzip /build-opencv/opencv.zip && mv opencv-4.2.0 opencv

RUN unzip /build-opencv/opencv_contrib.zip && \
    mv opencv_contrib-4.2.0 opencv_contrib
# there should be a better way to install pip ?
RUN python3 get-pip.py && pip3 install numpy

RUN ["/bin/mkdir", "opencv/build"]

WORKDIR /build-opencv/opencv/build
RUN rm -rf *
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D ENABLE_FAST_MATH=1 \
    -D CUDA_FAST_MATH=1 \
    -D CUDA_ARCH_BIN=$TARGET_CC \
    -D WITH_CUBLAS=1 \
    -D OPENCV_EXTRA_MODULES_PATH=/build-opencv/opencv_contrib/modules \
    -D HAVE_opencv_python3=ON \
    -D PYTHON_EXECUTABLE=/usr/bin/python3 \
    -D BUILD_EXAMPLES=ON ..

RUN make -j4 && make install

WORKDIR /build-opencv
RUN ["/bin/mkdir", "opencv/test"]
RUN ["/bin/mkdir", "opencv/test/yolov3"]
COPY test.mp4 ./opencv/test
COPY yolo_object_detection.py ./opencv/test
COPY yolov3 ./opencv/test/yolov3

WORKDIR /build-opencv/opencv/test
RUN pip3 install imutils
# read in video clip and generate a new one annotated with object detection
# reports FPS to stdout
CMD python3 ./yolo_object_detection.py -u 1 -y ./yolov3 -d 0 -i ./test.mp4 -o test_dnn.mp4 2>&1 | tee results.txt










