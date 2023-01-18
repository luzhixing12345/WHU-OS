
var global_before_copy_url;
var global_after_copy_url;

function add(block) {
    var clip_board = document.createElement('img');
    clip_board.id = 'code_copy';
    clip_board.src = global_before_copy_url;
    clip_board.onclick = function () {
        clip_board.src = global_after_copy_url;
        navigator.clipboard.writeText(block.firstChild.innerText);
    }
    block.appendChild(clip_board)
}

function remove(block) {
    var clip_board = document.getElementById('code_copy')
    block.removeChild(clip_board)
}

function addCodeCopy(before_copy_url, after_copy_url) {
    global_before_copy_url = before_copy_url;
    global_after_copy_url = after_copy_url;
    // 为所有代码段添加可以复制的标记
    var code_blocks = document.getElementsByTagName('pre')
    for (var i = 0; i < code_blocks.length; i++) {
        const code_block = code_blocks[i];
        code_block.addEventListener("mouseenter", () => add(code_block))
        code_block.addEventListener("mouseleave", () => remove(code_block))
    }
}