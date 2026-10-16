nimble install -g nimlangserver

nim c --mm:orc -d:release --threads:on cpubench.nim

upx --best ./cpubench
ls -l ./cpubench
echo ""
./cpubench
