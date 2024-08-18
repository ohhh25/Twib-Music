const apiLogger = (req, res, next) => {
    const method = req.method;
    const url = req.url;
    const time = new Date();
    console.log(`[${time}] ${method} ${url}`);
    next();
}

export default apiLogger;
