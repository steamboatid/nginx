function pr(x) {
    return new Promise(resolve => {resolve(x)});
}

async function add(x) {
    const a = await pr(x);

    throw a + 1;

    const b = await pr(x + 10);

    return a + b;
}

add(50).then(v => {console.log(v)});
