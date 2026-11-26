# Image to COE Workflow

This folder packages the image converter used in Falling Fish. The Python scripts are copied without behavioral changes from the archived converter; `requirements.txt` is converted from UTF-16 to UTF-8 with the same dependency pins.

## Attribution

- Upstream repository: https://github.com/amsheth/Image_to_COE
- Archived local upstream commit: `a0955569533ca366050f14ca25b5087e1711be6e`
- Upstream README author: Arnav Sheth; the README also credits Ian Dailis.
- See [the preserved upstream README](UPSTREAM_README.md) and [third-party notices](../../THIRD_PARTY_NOTICES.md).

The converter is third-party code. This packaging does not claim authorship of the converter. No top-level license file was found in the archived tool repository; confirm redistribution terms with the upstream project before publishing these copied scripts.

## Run the converter

The upstream README describes Python 3.11.1 on Windows. The pinned dependencies and instructions below have not been revalidated in a fresh environment.

From this directory:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python main.py
```

On Windows, activate the environment with `.venv\Scripts\Activate.ps1` instead.

The interactive prompts request an input image path, bits per pixel, and output width and height. Use a scratch copy of an image while experimenting: the script writes generated files beside the input image under its basename.

The converter generates indexed COE data, a SystemVerilog palette, example modules, and a preview image. Keep the COE and palette from the same conversion together. K-means clustering is not seeded, so regeneration is not guaranteed to reproduce the archived palette ordering.

## Vivado integration

1. Choose dimensions and color depth that fit the target FPGA's actual BRAM budget.
2. Configure a Block Memory Generator ROM with the generated width and depth, and load its COE file.
3. Integrate the paired palette into the display pipeline and account for ROM latency.
4. Check the result in simulation and on the display before replacing any archived assets.

The original script also emits Quartus-oriented files and M9K capacity messages. These are inherited from upstream and are not Spartan-7 resource estimates. Preserve the existing Vivado renderer and ROM configuration unless intentionally changing the implementation.

The final project's compiled image data remains in `src/coe/` at the repository root. Original archived PNG inputs are under `assets/sprites/source/`; their filenames do not establish a one-to-one match with the compiled final assets.
