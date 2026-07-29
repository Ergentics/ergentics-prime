enum PrimeEmbeddedBuildProvenance {
    #if DEBUG
        static let buildConfiguration = "debug"
    #else
        static let buildConfiguration = "release"
    #endif

    // This file is excluded only to avoid a self-referential digest. Runtime
    // verification requires this exact canonical template and digest; every
    // other admitted package, source, test, and architecture file is hashed.
    static let sourceIdentitySHA256 =
        "227f0f299ddf2c98051a0b05017e9155455c3e1fe871e8b6a954500c7d39a798"
}
