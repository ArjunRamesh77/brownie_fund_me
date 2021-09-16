from scripts.helpers import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from brownie import FundMe, MockV3Aggregator, network, config
from web3 import Web3


def deploy_fund_me():
    account = get_account()

    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        price_feed_address = deploy_mocks()

    fund_me = FundMe.deploy(price_feed_address, {"from": account})
    print(f"Contract deployed to {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
