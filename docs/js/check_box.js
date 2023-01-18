
var inputs = document.getElementsByTagName('input')
for(var i=0;i<inputs.length;i++) {
    inputs[i].removeAttribute('disabled')
    inputs[i].onclick = function() {
        return false;
    }
}

// 这里可以写一些在全局生效的代码

let markdown_part = document.getElementsByClassName('markdown-body')[0]
markdown_part.className = 'markdown-body markdown-light'
