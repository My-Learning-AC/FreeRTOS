#!/usr/bin/env bash

DEVID="14000000 F0290012 4022359E 1C37E403 20190600"

echo $DEVID | xxd -r -p > _data.bin

openssl dgst -sha256 -sign data/2k.rsa_private.txt _data.bin > _signature.bin
cat _signature.bin | xxd -p -c 64 > _tmp1.hex
openssl rsautl -inkey data/2k.rsa_private.txt -encrypt -raw -in _signature.bin | xxd -p -c64

echo 00000029 > _tmp2.hex
echo $DEVID >> _tmp2.hex
cat _tmp1.hex >> _tmp2.hex
sed -r "s/\s*(\w{2})(\w{2})(\w{2})(\w{2})/0x\4\3\2\1\n/g" _tmp2.hex | sed -r "/^$/d" > _output.hex
#rm _data.bin _tmp1.hex _tmp2.hex




