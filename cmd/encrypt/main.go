package main

import (
	"bufio"
	"crypto/rand"
	"encoding/base64"
	"flag"
	"fmt"
	"io"
	"log"
	"os"

	"golang.org/x/crypto/nacl/secretbox"
	"golang.org/x/crypto/scrypt"
	"golang.org/x/term"
)

const saltSize = 16 // size in bytes for the salt

// deriveKey derives a 32-byte key from a password using scrypt.
func deriveKey(password, salt []byte) (*[32]byte, error) {
	key, err := scrypt.Key(password, salt, 32768, 8, 1, 32)
	if err != nil {
		return nil, err
	}
	var keyArray [32]byte
	copy(keyArray[:], key)
	return &keyArray, nil
}

// encryptRaw encrypts the plaintext using NaCl's secretbox.
// It returns raw bytes containing: nonce || ciphertext.
func encryptRaw(plaintext []byte, key *[32]byte) ([]byte, error) {
	var nonce [24]byte
	if _, err := io.ReadFull(rand.Reader, nonce[:]); err != nil {
		return nil, err
	}
	encrypted := secretbox.Seal(nonce[:], plaintext, &nonce, key)
	return encrypted, nil
}

// decryptRaw decrypts the raw encrypted data produced by encryptRaw.
func decryptRaw(data []byte, key *[32]byte) ([]byte, error) {
	if len(data) < 24 {
		return nil, fmt.Errorf("encrypted data too short")
	}
	var nonce [24]byte
	copy(nonce[:], data[:24])
	decrypted, ok := secretbox.Open(nil, data[24:], &nonce, key)
	if !ok {
		return nil, fmt.Errorf("decryption error: invalid key or corrupt data")
	}
	return decrypted, nil
}

func main() {
	// Define flags to choose decryption mode.
	decryptFlag := flag.Bool("decrypt", false, "run in decryption mode")
    decryptFlagShort := flag.Bool("d", false, "run in decryption mode")
	flag.Parse()

    if *decryptFlag || *decryptFlagShort {
		// --- Decryption Mode ---
		reader := bufio.NewReader(os.Stdin)
		fmt.Print("Enter ciphertext: ")
		cipherInput, err := reader.ReadString('\n')
		if err != nil {
			log.Fatal("Failed to read ciphertext:", err)
		}
		fmt.Println()

		fmt.Print("Enter password: ")
		passInput, err := term.ReadPassword(int(os.Stdin.Fd()))
		if err != nil {
			log.Fatal("Failed to read password:", err)
		}
		fmt.Println()

		// Decode the full message (salt || nonce || ciphertext).
		fullData, err := base64.StdEncoding.DecodeString(string(cipherInput))
		if err != nil {
			log.Fatal("Failed to decode base64 ciphertext:", err)
		}
		if len(fullData) < saltSize {
			log.Fatal("Data too short: missing salt")
		}

		// Extract the salt and the actual encrypted data.
		salt := fullData[:saltSize]
		encryptedRaw := fullData[saltSize:]

		// Derive the key using the extracted salt.
		key, err := deriveKey(passInput, salt)
		if err != nil {
			log.Fatal("Key derivation failed:", err)
		}

		plaintext, err := decryptRaw(encryptedRaw, key)
		if err != nil {
			log.Fatal("Decryption failed:", err)
		}
		fmt.Println("Decrypted text:")
		fmt.Println(string(plaintext))
	} else {
		// --- Encryption Mode ---
		// Generate a random salt.
		salt := make([]byte, saltSize)
		if _, err := io.ReadFull(rand.Reader, salt); err != nil {
			log.Fatal("Failed to generate salt:", err)
		}

		fmt.Print("Enter plaintext: ")
		plainInput, err := term.ReadPassword(int(os.Stdin.Fd()))
		if err != nil {
			log.Fatal("Failed to read plaintext:", err)
		}
		fmt.Println()

		fmt.Print("Enter password: ")
		passInput, err := term.ReadPassword(int(os.Stdin.Fd()))
		if err != nil {
			log.Fatal("Failed to read password:", err)
		}
		fmt.Println()

		// Derive a key from the password using the random salt.
		key, err := deriveKey(passInput, salt)
		if err != nil {
			log.Fatal("Key derivation failed:", err)
		}

		encryptedRaw, err := encryptRaw(plainInput, key)
		if err != nil {
			log.Fatal("Encryption failed:", err)
		}

		// Prepend the salt to the encrypted data.
		finalData := append(salt, encryptedRaw...)
		encoded := base64.StdEncoding.EncodeToString(finalData)
		fmt.Println("Encrypted text:")
		fmt.Println(encoded)
	}
}
