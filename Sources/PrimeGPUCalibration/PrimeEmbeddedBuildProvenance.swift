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
        "4662c32edd7c82637fd61736e8a57b207857451d4f8b92169d187b690e3dd13d"
}
