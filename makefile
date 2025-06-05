-include .env

build:
	forge build

test:
	forge test --via-ir

deployTestnet:
	forge script script/DeployRubyScoreID.s.sol:DeployRubyScoreIDScript \
	--sig "runTestnet()" \
	-vvvv \
	--etherscan-api-key ${BASESCAN_API_KEY} \
# 	--verify \
# 	--broadcast

deployMainnet:
	forge script script/DeployRubyScoreID.s.sol:DeployRubyScoreIDScript \
	--sig "runMainnet()" \
	-vvvv \
	--etherscan-api-key ${BASESCAN_API_KEY} \
# 	--verify \
# 	--broadcast

updateMainnet:
	forge script script/DeployRubyScoreID.s.sol:DeployRubyScoreIDScript \
	--sig "updateMainnet()" \
	-vvvv \
	--etherscan-api-key ${BASESCAN_API_KEY} \
# 	--verify \
# 	--broadcast

signDigest:
	forge script script/GenerateSignature.s.sol:GenerateSignatureScript \
	$(digest) \
	--sig "run(bytes32)" \
	-vv \
