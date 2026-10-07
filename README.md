# Lunar127 Showcase 0.3.1 — TIFF-GIF Processable Hologram

This corrective build replaces the prior static-looking TIFF carrier with a **temporal processable image cartridge**.

## What “TIFF-GIF” means in this build

TIFF and GIF are different standard image containers. Lunar127 therefore uses one logical processable-hologram format with **two lossless, interchangeable encodings**:

- `cartridge/Lunar127_Showcase_0.3.1_PROCESSABLE.tiff` — an ordered multi-page TIFF.
- `cartridge/Lunar127_Showcase_0.3.1_PROCESSABLE.gif` — an actual animated GIF89a frame stream.

The GIF visibly spools when opened in an ordinary animated-image viewer. The TIFF contains the same ordered logical frame stream as pages. They decode to the same image-resident archive and machine.

## Authoritative processing cycle

Every VM quantum is intended to use the active image itself as the authoritative machine:

`DECODE FRAMES -> PHASE UNWRAP -> VERIFY FRAME CHAIN/HASHES -> REASSEMBLE IMAGE ARCHIVE -> VERIFY IMMUTABLE BANKS -> EXECUTE IMAGE-RESIDENT BYTECODE -> UPDATE COMPLETE STATE -> JOURNAL -> REPACK -> PHASE-TEXTURE FRAMES -> ENCODE TIFF/GIF -> REREAD/VERIFY -> ATOMIC COMMIT`

The data frames are not screenshots. Each 512×512 frame is 8-bit processable image memory. A reversible coordinate/frame/tick-dependent phase texture is applied to the payload before it is represented as pixels. The generic harness reverses the texture and validates the page payload and ordered page chain before execution.

## External boundary

Only these pieces are outside the processable image:

- `harness/TIFFGifHoloHarness.cs` — generic C# TIFF/GIF evaluator, VM interpreter and virtual-console primitives.
- `BOOT.cmd` and the build/verify/inspect/reset command wrappers.
- Windows/.NET Framework plus ordinary host graphics, audio, input, loopback and filesystem primitives.
- A writable `workspace` for the current image and explicit checkpoint copies.

All Lunar127-specific VM program, mission logic, physics data, scene graph, HD assets, materials, HUD definition, terminal/VFS, state, trajectory, journal, checkpoint metadata, integrity maps and temporal-spool definition are image-resident.

## Run

Double-click:

    BOOT.cmd

That defaults to the animated GIF as the active authoritative carrier. To use the multi-page TIFF encoding instead:

    BOOT.cmd tiff

To start again from the seed image:

    BOOT.cmd gif reset
    BOOT.cmd tiff reset

The C# harness is rebuilt locally from the supplied Hotfix 4 source on every boot using the Windows .NET Framework C# compiler. This prevents an older previously compiled evaluator from being reused after an overlay update.

## Important engineering boundary

This is an image-resident virtual machine design, not a claim that TIFF/GIF pixels physically execute without a CPU. The external C# evaluator is the declared generic platform boundary. The simulation-specific machine is carried by the image.

## Hotfix 3: persistent Windows shell

This package intentionally keeps `BOOT.cmd` open while the evaluator GUI is running and after it exits. Startup and runtime exceptions are recorded in `workspace\logs\runtime.log` instead of disappearing with a transient shell window.

If a machine blocks the optional 127.0.0.1 loopback listener, run `BOOT_DIRECT.cmd reset`. The on-screen terminal remains functional because direct console input does not require the loopback transport.

For a build-and-carrier check that does not start the GUI, run `DIAGNOSE.cmd`. It also stays open on failure.


## Hotfix 3 compiler correction

Hotfix 3 corrects Windows C# compiler error CS0160 in `SimulationForm.SafeBegin`. `ObjectDisposedException` derives from `InvalidOperationException`, so the specific catch must precede the broader catch. The build now catches `ObjectDisposedException` first and then `InvalidOperationException`. `BUILD_HARNESS.cmd` also persists all C# compiler output to `workspace\logs\build.log` and echoes it on failure. The persistent boot shell remains enabled.

## Hotfix 4: crash-safe Windows boot

Hotfix 4 hardens the stage after a successful compile, where the evaluator could disappear before a usable virtual console was established. The GUI harness is now compiled as a console-attached managed executable, direct mode is the safe default, the image quantum scheduler starts only after the WinForms window is visible, and asynchronous loopback client failures are contained instead of being able to terminate the process. Image-resident PNG decode failures are degraded to logged placeholders rather than aborting startup.

Use:

    BOOT.cmd reset

For an explicit loopback-enabled run:

    BOOT.cmd loopback reset

Run `DIAGNOSE.cmd` first if desired. It verifies both carriers and performs a semantic runtime/asset smoke load without starting the full GUI. The build log is `workspace\logs\build.log`; the runtime log is `workspace\logs\runtime.log`.
