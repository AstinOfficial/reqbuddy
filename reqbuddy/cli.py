import argparse
from .core import get_requirement

def main():
    parser = argparse.ArgumentParser(description="Get cleaned Python requirements.")
    parser.add_argument(
        "-s", action="store_true", help="Strip version specifiers from packages"
    )
    parser.add_argument(
        "-d", action="store_true", help="Remove duplicate packages"
    )
    parser.add_argument(
        "-p", type=str, default=None, help="Path to requirements.txt file"
    )
    args = parser.parse_args()

    reqs = get_requirement(
        requirements_path=args.p,
        strip_versions=args.s,
        deduplicate=args.d
    )
    for r in reqs:
        print(r)

if __name__ == "__main__":
    main()
