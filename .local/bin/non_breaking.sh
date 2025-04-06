#!/bin/bash
# Name of the file where to save packages that can be uninstalled
RESULT="removable_packages.txt"
ERRORS="packages_with_dependencies.txt"
# Delete the files if they already exist
> "$RESULT"
> "$ERRORS"
echo "Analyzing installed packages..."
# Get the list of all installed packages
PACKAGES=$(pacman -Qq)
# Total packages to analyze
TOTAL=$(echo "$PACKAGES" | wc -l)
COUNTER=0
# For each package, verify if it can be removed without breaking dependencies
for PKG in $PACKAGES; do
    COUNTER=$((COUNTER + 1))
    echo -ne "Analyzing package $COUNTER of $TOTAL: $PKG\r"

    # Try to uninstall the package without actually doing it (simulation)
    if pacman -Rp "$PKG" &>/dev/null; then
        # The package can be removed without breaking dependencies
        echo "$PKG" >> "$RESULT"
    else
        # The package cannot be removed because other packages depend on it
        echo "$PKG" >> "$ERRORS"
    fi
done
echo -e "\n\nAnalysis completed."
echo "Packages that can be removed: $(wc -l < "$RESULT")"
echo "Packages that cannot be removed: $(wc -l < "$ERRORS")"
echo "The results have been saved in $RESULT and $ERRORS"
