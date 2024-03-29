# Change ACCOUNT_ADDR to the account address you want to generate a key for and 
# DIR to the directory of the algorand node.
# The key starts from current round and last for 3,000,000 rounds.
# A key registration transaction (to be signed) will be created in the current folder.

ACCOUNT_ADDR="HMVENN4CKPVFDSL7IBLTMNMANW3IED23GQKHGWKWOQCHAWBWIPHUEDW55M"
DIR="/var/lib/algorand"
USER="gws"

FIRST_ROUND=$(goal node status -d /var/lib/algorand | awk 'FNR == 1 {print $4}')
LAST_ROUND=$(($FIRST_ROUND + 3000000))
KEY_FILE="$DIR/mainnet-v1.0/$ACCOUNT_ADDR.$FIRST_ROUND.$LAST_ROUND.partkey"

# generate the participation key
sudo -u algorand goal account addpartkey -a $ACCOUNT_ADDR \
    --roundFirstValid=$FIRST_ROUND --roundLastValid=$LAST_ROUND -d $DIR

# generate the key registration transaction
# WARNING: This command must be run on the node where the partkey lives and the node
# must only have a single partkey for the account. Otherwise the command will
# choose one at random.
sudo -u algorand goal account changeonlinestatus --address=$ACCOUNT_ADDR \
    --fee=2000 --firstvalid=$FIRST_ROUND --lastvalid=$(($FIRST_ROUND + 1000)) \
    --online=true --txfile=$DIR/online.txn -d $DIR

# move it to the current folder owned by the current user
sudo chown $USER:$USER $DIR/online.txn
sudo mv $DIR/online.txn .

TOKEN=$(cat $DIR/algod.admin.token)
URL=$(cat $DIR/algod.net)

echo "1. Now sign and send the transaction in 'online.txn'"
echo "Use a command like this for ledger hw wallet signing:"
echo "goal clerk sign -i online.txn -o signed.txn -w Ledger-Nano-X-0001-4b832de889f7db62bbff8c6e18494172 -d ~/dev/algorand/node/data"
echo
echo "2. After at least 320 rounds check that the node is participating in consensus:"
echo "   >>  grep 'VoteBroadcast' node.log"
echo
echo "3. Then delete the old participation key"
echo '$ curl -X DELETE $URL/v2/participation/$partKeyID -H "X-Algo-API-Token: $TOKEN"'

