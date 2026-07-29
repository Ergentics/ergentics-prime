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
        "d4d201ba92b06711703ce2d8c0c4137ced43dc405d13ed0c515e5091b82c191f"
}
