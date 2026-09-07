// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore

/// The only DriverCore addition for Gate B: translate the already-validated
/// frozen intent into semantic roots. PrimeCore owns the retained state,
/// one-shot transfer and fixed role policy. Execution remains unavailable
/// until Gate C adds continuous Prime and companion guards.
package enum PrimeValidationDriverV2RoleBridge {
    package static func roleContext(
        from intent: PrimeValidationRunIntentV2
    ) throws -> PrimeValidationDriverV2RoleContext {
        try PrimeValidationExecutorAdmissionPolicyV2.frozenV1.validate(
            intent: intent
        )
        let roots = intent.roots
        return PrimeValidationDriverV2RoleContext(
            repositoryRoot: roleRoot(roots.repositoryRoot),
            companionRoot: roleRoot(roots.companionRoot),
            workspaceRoot: roleRoot(roots.workspaceRoot),
            evidenceRoot: roleRoot(roots.evidenceRoot),
            scratchAbsolutePath: roots.scratchAbsolutePath,
            cacheAbsolutePath: roots.cacheAbsolutePath,
            configAbsolutePath: roots.configAbsolutePath,
            securityAbsolutePath: roots.securityAbsolutePath,
            clangModuleCacheAbsolutePath:
                roots.clangModuleCacheAbsolutePath,
            outputAbsolutePath: roots.outputAbsolutePath,
            homeAbsolutePath: roots.homeAbsolutePath,
            swiftPMModuleCacheAbsolutePath:
                roots.swiftPMModuleCacheAbsolutePath,
            temporaryAbsolutePath: roots.temporaryAbsolutePath,
            requiredPinnedMetallibAbsolutePath:
                PrimeValidationDriverV2Validation.appending(
                    intent.requiredPinnedMetallib.relativePath,
                    to: roots.workspaceRoot.absolutePath
                ),
            evidenceRunID: intent.runID,
            requiredPinnedMetallibByteCount:
                intent.requiredPinnedMetallib.content.byteCount,
            requiredPinnedMetallibSHA256:
                intent.requiredPinnedMetallib.content.sha256
        )
    }

    private static func roleRoot(
        _ binding: PrimeValidationDirectoryBindingV2
    ) -> PrimeValidationDriverV2RoleRootContext {
        PrimeValidationDriverV2RoleRootContext(
            absolutePath: binding.absolutePath,
            deviceID: binding.deviceID,
            inode: binding.inode,
            ownerUserID: binding.ownerUserID,
            permissionMode: binding.mode
        )
    }
}
