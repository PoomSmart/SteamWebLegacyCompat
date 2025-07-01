module.exports = {
    presets: [
        ["@babel/preset-env", {
            targets: {
                browsers: ["ios >= 12"]
            },
        }]
    ]
};
