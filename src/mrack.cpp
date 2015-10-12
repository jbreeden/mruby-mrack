#include "mruby_APR.h"
#include "mruby/compile.h"

struct socket_thread_args {
  apr_pool_t* pool;
  apr_socket_t* socket;
};

static void* 
run_socket_thread(apr_thread_t* thread, void* args_ptr) {
  socket_thread_args* args = (socket_thread_args*)args_ptr;
  mrb_state* mrb = mrb_open();
  mrb_value socket = mruby_box_apr_socket_t(mrb, args->socket);
  mrb_value pool = mruby_box_apr_pool_t(mrb, args->pool);
  mrb_gv_set(mrb, mrb_intern_cstr(mrb, "$socket"), socket);
  mrb_gv_set(mrb, mrb_intern_cstr(mrb, "$pool"), pool);
  FILE* rackup_file = fopen("config.ru", "r");
  mrb_load_file(mrb, rackup_file);
  apr_pool_destroy(args->pool);
  mrb_close(mrb);
  return NULL;
}

mrb_value
mrb_MRack_accept_client(mrb_state* mrb, mrb_value self) {
  mrb_value socket;
  mrb_get_args(mrb, "o", &socket);
  if (!mrb_obj_is_kind_of(mrb, socket, AprSocketT_class(mrb))) {
    mrb_raise(mrb, E_TYPE_ERROR, "AprSocketT expected");
  }
  apr_socket_t* native_socket = mruby_unbox_apr_socket_t(socket);
  
  apr_threadattr_t* threadattr;
  apr_pool_t* threadpool;
  apr_pool_create(&threadpool, NULL);
  apr_threadattr_detach_set(threadattr, 1);
  apr_threadattr_create(&threadattr, threadpool);
  apr_thread_t* thread;
  socket_thread_args* args = (socket_thread_args*)malloc(sizeof(socket_thread_args));
  args->pool = threadpool;
  args->socket = native_socket;
  apr_thread_create(&thread, threadattr, run_socket_thread, args, threadpool);
  return self;
}

#ifdef __cplusplus
extern "C" {
#endif

void mrb_mruby_mrack_gem_init(mrb_state* mrb) {
  RClass* MRack_module = mrb_define_module(mrb, "MRack");
  mrb_define_class_method(mrb, MRack_module, "accept_client", mrb_MRack_accept_client, MRB_ARGS_ARG(1, 0));
}

void mrb_mruby_mrack_gem_final(mrb_state* mrb) {}

#ifdef __cplusplus
}
#endif

