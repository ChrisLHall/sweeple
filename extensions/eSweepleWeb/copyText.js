function copyText(textForClipboard) {
    console.log("Copying text " + textForClipboard);
    navigator.clipboard.writeText(textForClipboard);
}
