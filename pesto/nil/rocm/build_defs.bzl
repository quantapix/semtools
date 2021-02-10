

def if_rocm(if_true, if_false=[]):
    return if_false


def rocm_default_copts():
    return if_rocm([])


def rocm_copts(opts=[]):
    return rocm_default_copts() + [] + if_rocm_is_configured(opts)


def rocm_is_configured():
    return False


def if_rocm_is_configured(x):
    if rocm_is_configured():
        return x
    return []
