#
# Cryptographic API
#

obj-m += crypto.o
crypto-y := api.o cipher.o compress.o

obj-m += crypto_wq.o

obj-m += fips.o

crypto_algapi-m += proc.o
crypto_algapi-y := algapi.o scatterwalk.o $(crypto_algapi-y)
obj-m += crypto_algapi.o

obj-m += aead.o

crypto_blkcipher-y := ablkcipher.o
crypto_blkcipher-y += blkcipher.o
obj-m += crypto_blkcipher.o
obj-m += chainiv.o
obj-m += eseqiv.o
obj-m += seqiv.o

crypto_hash-y += ahash.o
crypto_hash-y += shash.o
obj-m += crypto_hash.o

obj-m += pcompress.o

cryptomgr-y := algboss.o testmgr.o

obj-m += cryptomgr.o
obj-m += crypto_user.o
obj-m += hmac.o
obj-m += vmac.o
obj-m += xcbc.o
obj-m += crypto_null.o
obj-m += md4.o
obj-m += md5.o
obj-m += rmd128.o
obj-m += rmd160.o
obj-m += rmd256.o
obj-m += rmd320.o
obj-m += sha1_generic.o
obj-m += sha256_generic.o
obj-m += sha512_generic.o
obj-m += wp512.o
obj-m += tgr192.o
obj-m += gf128mul.o
obj-m += ecb.o
obj-m += cbc.o
obj-m += pcbc.o
obj-m += cts.o
obj-m += lrw.o
obj-m += xts.o
obj-m += ctr.o
obj-m += gcm.o
obj-m += ccm.o
obj-m += pcrypt.o
obj-m += cryptd.o
obj-m += des_generic.o
obj-m += fcrypt.o
obj-m += blowfish_generic.o
obj-m += blowfish_common.o
obj-m += twofish_generic.o
obj-m += twofish_common.o
obj-m += serpent_generic.o
obj-m += aes_generic.o
obj-m += camellia_generic.o
obj-m += cast5.o
obj-m += cast6.o
obj-m += arc4.o
obj-m += tea.o
obj-m += khazad.o
obj-m += anubis.o
obj-m += seed.o
obj-m += salsa20_generic.o
obj-m += deflate.o
obj-m += zlib.o
obj-m += michael_mic.o
obj-m += crc32c.o
obj-m += authenc.o authencesn.o
obj-m += lzo.o
obj-m += rng.o
obj-m += krng.o
obj-m += ansi_cprng.o
obj-m += tcrypt.o
obj-m += ghash-generic.o
obj-m += af_alg.o
obj-m += algif_hash.o
obj-m += algif_skcipher.o

#
# generic algorithms and the async_tx api
#
obj-m += xor.o
obj-m += async_tx/
