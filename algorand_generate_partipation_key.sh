# Change ACCOUNT_ADDR to the account address you want to generate a key for and 
# DIR to the directory of the algorand node.
# The key starts from current round and last for 3,000,000 rounds.
# A key registration transaction (to be signed) will be created in the current folder.

ACCOUNT_ADDR="UXQAJJQV6GJNQMV53WQUYQTSJIMRGMT224IECW6HGSWOTXBICXCTUJ635E"
DIR="/var/lib/algorand"

FIRST_ROUND=$(goal node status -d /var/lib/algorand | awk 'FNR == 1 {print $4}')
LAST_ROUND=$(($FIRST_ROUND + 3000000))
KEY_FILE="$DIR/mainnet-v1.0/$ACCOUNT_ADDR.$FIRST_ROUND.$LAST_ROUND.partkey"

# generate the participation key
sudo -u algorand goal account addpartkey -a $ACCOUNT_ADDR \
    --roundFirstValid=$FIRST_ROUND --roundLastValid=$LAST_ROUND -d $DIR

echo "Participation key generated"
echo "Examine it running 'goal account partkeyinfo'"
