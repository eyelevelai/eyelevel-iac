env = dict(
    deviceType="${deviceType}",
    searchBroker="redis://${cacheAddr}:${cachePort}/0",
    searchResultBroker="redis://${cacheAddr}:${cachePort}/0",
    searchLog="${rankerService}",
    validAPIKeys=["${validAPIKey}", "${validUsername}"],
)
