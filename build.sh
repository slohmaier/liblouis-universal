echo "Building liblouis.dylib"
echo "======================"
echo "This script will build a universal dylib for liblouis."

# Clone liblouis
if [ -e "liblouis/.git" ]; then
    cd liblouis || exit 1
    git pull || exit 1
else
    git clone https://github.com/liblouis/liblouis.git || exit 1
    cd liblouis || exit 1
fi

git checkout v3.25.0 || exit 1

echo "Building liblouis for x86_64"

./autogen.sh || exit 1
./configure

# Compile for x86_64
if [ ! -e liblouis_x86_64.dylib ]; then 
    make clean || exit 1
    make CFLAGS="-arch x86_64" || exit 1
    cp liblouis/.libs/liblouis.dylib liblouis_x86_64.dylib || exit 1
    make clean
fi

# Compile for arm64
if [ ! -e liblouis_arm64.dylib ]; then
    make clean || exit 1
    make CFLAGS="-arch arm64" || exit 1
    cp liblouis/.libs/liblouis.dylib liblouis_arm64.dylib || exit 1
    make clean
fi

# Combine architectures into a universal dylib
echo "Combining architectures into a universal dylib"
mkdir -p ../louis || exit 1
lipo -create -output ../louis/liblouis.20.dylib liblouis_x86_64.dylib liblouis_arm64.dylib || exit 1
cd .. || exit 1
cp liblouis/python/louis/__init__.py.in louis/__init__.py || exit 1
cat liblouis/python/louis/__init__.py.in | sed -E "s@^liblouis = @import os\nos.environ['LOUIS_TABLEPATH'] = os.path.dirname(os.path.abspath(__file__))+'/tables'\nliblouis = @g" \
    | sed "s@\"###LIBLOUIS_SONAME###\"@os.path.dirname(os.path.abspath(__file__))+'/liblouis.20.dylib'@g" > louis/__init__.py || exit 1
cp -r liblouis/tables/ louis/tables || exit 1
python3 test.py || exit 1
