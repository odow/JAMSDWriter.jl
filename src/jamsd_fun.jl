mutable struct abstract_var
end

mutable struct context
end

mutable struct empinfo
end

mutable struct empinfo_equil
end

mutable struct equtree
end

mutable struct equnode
end

mutable struct jamsd_var
end

mutable struct jamsd_equ
end

mutable struct jamsd_sp_matrix
end

mutable struct mathprgm
end

mutable struct ovf_definition
end

mutable struct option
	name::Vector{Cchar}
	typ::Cint
	value::Cdouble
end

function ctx_add_lin_var(ctx::Ptr{context}, eidx, vidx, coeff::Cdouble)
	equ = ctx_getequ(ctx, eidx)
	res = ccall((:equ_add_var, "libjamsd"), Cint, (Ptr{context}, Ptr{jamsd_equ}, Cint, Cdouble), ctx, equ, vidx, coeff)
	res != 0 && error("return code $res from JAMSD")
end

function ctx_create(n, m)
	ctx = ccall((:ctx_alloc, "libjamsd"), Ptr{context}, (Cuint,), 2)
	res = ccall((:model_reserve_eqns, "libjamsd"), Cint, (Ptr{context}, Ptr{Void}, Cuint), ctx, C_NULL, m);
	res != 0 && error("return code $res from JAMSD")
	res = ccall((:model_reserve_vars, "libjamsd"), Cint, (Ptr{context}, Ptr{Void}, Cuint), ctx, C_NULL, n);
	res != 0 && error("return code $res from JAMSD")
	res = ccall((:ctx_resize, "libjamsd"), Cint, (Ptr{context}, Cuint, Cuint), ctx, n, m)
	res != 0 && error("return code $res from JAMSD")
	return ctx
end

function ctx_getvar(ctx, idx)
	return ccall((:ctx_getvar, "libjamsd"), Ptr{jamsd_var}, (Ptr{context}, Cint), ctx, idx)
end

function ctx_m(ctx)
	return ccall((:ctx_m, "libjamsd"), Cint, (Ptr{context},), ctx)
end

function ctx_n(ctx)
	return ccall((:ctx_n, "libjamsd"), Cint, (Ptr{context},), ctx)
end

function ctx_setvarnames(ctx, names::Vector{String})
	res = ccall((:myo_set_varnames, "libjamsd"), Cint, (Ptr{context}, Ptr{Ptr{Cchar}}, Cuint), ctx, names, length(names))
	res != 0 && error("return code $res from JAMSD")
end

function hack_last_vidx(ctx)
	return ccall((:model_total_n, "libjamsd"), Csize_t, (Ptr{context},), ctx) - 1
end

function hack_exportempinfo(ctx, ctx_mtr, emp)
	res = ccall((:hack_exportempinfo, "libjamsd"), Cint, (Ptr{context}, Ptr{context}, Ptr{empinfo}), ctx, ctx_mtr, emp)
	res != 0 && error("return code $res from JAMSD")
end

function hack_solver_log()
	ccall((:hack_solver_log, "libjamsd"), Void, ())
end

function ctx_setvarlone(ctx::Ptr{context}, idx, val::Cdouble)
	res = ccall((:ctx_setvarlone, "libjamsd"), Cint, (Ptr{context}, Cint, Cdouble), ctx, idx, val)
	res != 0 && error("return code $res from JAMSD")
end

function ctx_getvarval(ctx::Ptr{context}, idx)
	val = Ref{Cdouble}(NaN)
	res = ccall((:ctx_getvarlone, "libjamsd"), Cint, (Ptr{context}, Cint, Ref{Cdouble}), ctx, idx, val)
	res != 0 && error("return code $res from JAMSD")
	return val.x
end

function ctx_getvarmult(ctx::Ptr{context}, idx)
	val = Ref{Cdouble}(NaN)
	res = ccall((:ctx_getvarmone, "libjamsd"), Cint, (Ptr{context}, Cint, Ref{Cdouble}), ctx, idx, val)
	res != 0 && error("return code $res from JAMSD")
	return val.x
end

function ctx_getequ(ctx, idx)
	equ = ccall((:ctx_getequ, "libjamsd"), Ptr{jamsd_equ}, (Ptr{context}, Cint), ctx, idx)
end


function ctx_getmultiplierval(ctx::Ptr{context}, idx)
	val = Ref{Cdouble}(NaN)
	res = ccall((:ctx_getequmone, "libjamsd"), Cint, (Ptr{context}, Cint, Ref{Cdouble}), ctx, idx, val)
	res != 0 && error("return code $res from JAMSD")
	return val.x
end

function emp_create(ctx)
	return ccall((:empinfo_alloc, "libjamsd"), Ptr{empinfo}, (Ptr{context},), ctx)
end

#function emp_create_equil(emp)
#	return ccall((:equil_alloc, "libjamsd"), Ptr{empinfo_equil}, (Ptr{empinfo},), emp)
#end

function emp_hack(emp)
	res = ccall((:hack_ag_addfinish, "libjamsd"), Cint, (Ptr{empinfo},), emp)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_ensure(emp, nb)
	res = ccall((:mathprgm_ensure, "libjamsd"), Cint, (Ptr{empinfo}, Cuint), emp, nb)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_store(emp, mp::Ptr{mathprgm})
	res = ccall((:mathprgm_store, "libjamsd"), Cint, (Ptr{empinfo}, Ptr{mathprgm}), emp, mp)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_alloc(ctx, id)
	mp = ccall((:mathprgm_alloc, "libjamsd"), Ptr{mathprgm}, (Cint, Ptr{context}), id, ctx)
	return mp
end

function emp_mp_start(mp, typ, mode)
	res = ccall((:mathprgm_addstart, "libjamsd"), Cint, (Ptr{mathprgm}, Cuint, Cuint), mp, typ, mode)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_objdir(mp, sense)
	res = ccall((:mathprgm_addobjdir, "libjamsd"), Cint, (Ptr{mathprgm}, Cint), mp, sense_to_jamsd[sense])
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_objequ(mp, idx)
	res = ccall((:mathprgm_addobjequ, "libjamsd"), Cint, (Ptr{mathprgm}, Cint), mp, idx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_objvar(mp, idx)
	res = ccall((:mathprgm_addobjvar, "libjamsd"), Cint, (Ptr{mathprgm}, Cint), mp, idx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_var(mp, idx)
	res = ccall((:mathprgm_addvar, "libjamsd"), Cint, (Ptr{mathprgm}, Cint), mp, idx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_constraint(mp, idx)
	res = ccall((:mathprgm_addconstraint, "libjamsd"), Cint, (Ptr{mathprgm}, Cint), mp, idx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_vipair(mp, eidx, vidx)
	res = ccall((:mathprgm_addvipair, "libjamsd"), Cint, (Ptr{mathprgm}, Cint, Cint), mp, eidx, vidx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_mp_to_agent(ctx, emp)
	res = ccall((:mathprgm_to_agent, "libjamsd"), Cint, (Ptr{context}, Ptr{empinfo}), ctx, emp)
	res != 0 && error("return code $res from JAMSD")
end

function emp_report_values(emp, ctx)
	res = ccall((:empinfo_report_values, "libjamsd"), Cint, (Ptr{empinfo}, Ptr{context}), emp, ctx)
	res != 0 && error("return code $res from JAMSD")
end

function emp_ovf(emp, name, ovf_vidx, args)
	ovf_def = Ref{Ptr{ovf_definition}}(C_NULL)
	res = ccall((:ovf_add, "libjamsd"), Cint, (Ptr{empinfo}, Cstring, Cint, Cuint, Ptr{Cint}, Ref{Ptr{ovf_definition}}),
							                               emp, name, ovf_vidx, length(args), args, ovf_def)
	res != 0 && error("return code $res from JAMSD")

	return ovf_def.x
end

function emp_ovf_param(ovf_def, param_name, scalar::Number)
	res = ccall((:ovf_param_add_scalar, "libjamsd"), Cint, (Ptr{ovf_definition}, Cstring, Cdouble), ovf_def, param_name, scalar)
	res != 0 && error("return code $res from JAMSD")
end

function emp_ovf_param(ovf_def, param_name, arr::Vector)
  arrC = Vector{Cdouble}(arr)
	res = ccall((:ovf_param_add_vector, "libjamsd"), Cint, (Ptr{ovf_definition}, Cstring, Cuint, Ptr{Cdouble}), ovf_def, param_name, length(arr), arrC)
	res != 0 && error("return code $res from JAMSD")
end

function emp_ovf_check(ovf_def)
	res = ccall((:ovf_check, "libjamsd"), Cint, (Ptr{ovf_definition},), ovf_def)
end

function equtree_var(ctx, tree, node, idx, coeff)
	res = ccall((:equtree_var, "libjamsd"), Cint, (Ptr{context}, Ptr{equtree}, Ref{Ref{Ptr{equnode}}}, Cint, Cdouble),
		ctx,
		tree,
		node,
		idx,
		coeff)
	res != 0 && error("return code $res from JAMSD")
end

function equtree_cst(ctx, tree, node, value)
	res = ccall((:equtree_cst, "libjamsd"), Cint, (Ptr{context}, Ptr{equtree}, Ref{Ref{Ptr{equnode}}}, Cdouble),
		ctx,
		tree,
		node,
		value)
	res != 0 && error("return code $res from JAMSD")
end

function equtree_arithm(tree, node, opcode, nb)
	res = ccall((:equtree_arithm, "libjamsd"), Cint, (Ptr{equtree}, Ref{Ref{Ptr{equnode}}}, Cuint, Cuint),
		tree,
		node,
		opcode,
		nb)
	res != 0 && error("return code $res from JAMSD")
end

function equtree_call(ctx, tree, node, fndata)
	res = ccall((:equtree_call, "libjamsd"), Cint, (Ptr{context}, Ptr{equtree}, Ref{Ref{Ptr{equnode}}}, Cuint, Cuint),
		ctx,
		tree,
		node,
		fndata[1],
		fndata[2]
		)
	res != 0 && error("return code $res from JAMSD")
end

function equtree_get_root_addr(tree::Ptr{equtree}, node::Ref{Ref{Ptr{equnode}}})
	res = ccall((:equtree_get_root_addr, "libjamsd"), Cint, (Ptr{equtree}, Ref{Ref{Ptr{equnode}}}),
		tree,
		node)
	res != 0 && error("return code $res from JAMSD")
end

function equtree_umin(ctx, tree, node)
	res = ccall((:equtree_umin, "libjamsd"), Cint, (Ptr{equtree}, Ref{Ref{Ptr{equnode}}}),
		tree,
		node)
	res != 0 && error("return code $res from JAMSD")
end

function equnode_get_child_addr(node::Ptr{equnode}, i::Int)
	child = Ref{Ref{Ptr{equnode}}}(C_NULL)
	res = ccall((:equnode_get_child_addr, "libjamsd"), Cint, (Ptr{equnode}, Ref{Ref{Ptr{equnode}}}, Cuint),
		node,
		child,
		i)
	res != 0 && error("return code $res from JAMSD")
	return child
end

function equnode_deref(node::Ref{Ref{Ptr{equnode}}})
	return ccall((:p2deref, "libjamsd"), Ptr{equnode}, (Ref{Ref{Ptr{equnode}}},), node)
end

function ctx_get_solvername(ctx::Ptr{context})
	str = "?"^256
	res = ccall((:ctx_getsolverstr, "libjamsd"), Cint, (Ptr{context}, Cstring, Cuint), ctx, str, length(str))
	res != 0 && error("return code $res from JAMSD")
	return str
end

function jamsd_add_box_var(ctx::Ptr{context}, lower::Cdouble, upper::Cdouble)
	res = ccall((:model_add_box_var, "libjamsd"), Cint, (Ptr{context}, Cdouble, Cdouble), ctx, lower, upper)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_add_free_var(ctx::Ptr{context}, nb)
	res = ccall((:model_add_free_vars, "libjamsd"), Cint, (Ptr{context}, Cuint), ctx, nb)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_add_neg_var(ctx::Ptr{context}, nb)
	res = ccall((:model_add_neg_vars, "libjamsd"), Cint, (Ptr{context}, Cuint), ctx, nb)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_add_pos_var(ctx::Ptr{context}, nb)
	res = ccall((:model_add_pos_vars, "libjamsd"), Cint, (Ptr{context}, Cuint), ctx, nb)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_avar(size, indices)
	indicesC = Array{Cint, 1}(indices)
	return ccall((:avar_alloc, "libjamsd"), Ptr{abstract_var}, (Cuint, Ptr{Cint}), size, indicesC)
end

function jamsd_avar_free(avar::Ptr{abstract_var})
	return ccall((:avar_free, "libjamsd"), Void, (Ptr{abstract_var},), avar)
end

function jamsd_decl_eqn(ctx::Ptr{context}, idx)
	minn = Ref{Cint}(-1)
	res = ccall((:model_add_eqn_empty, "libjamsd"), Cint, (Ptr{context}, Ref{Cint}, Ptr{Void}, Cint), ctx, minn, C_NULL, 0)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_equ_add_lin_tree(ctx::Ptr{context}, eidx, qvals, avar::Ptr{abstract_var}, coeff)
	equ = ctx_getequ(ctx, eidx)
	res = ccall((:equ_add_lin_tree, "libjamsd"), Cint, (Ptr{context}, Ptr{jamsd_equ}, Ref{Cdouble}, Ptr{abstract_var}, Cdouble),
							ctx, equ, qvals, avar, coeff)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_equ_add_quadratic(ctx::Ptr{context}, eidx, mat::Ptr{jamsd_sp_matrix}, avar::Ptr{abstract_var}, coeff)
	equ = ctx_getequ(ctx, eidx)
	res = ccall((:equ_add_quadratic, "libjamsd"), Cint, (Ptr{context}, Ptr{jamsd_equ}, Ptr{jamsd_sp_matrix}, Ptr{abstract_var}, Cdouble),
							ctx, equ, mat, avar, coeff)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_mat_coo(ridx, cidx, vals)
	# beaware of dragons! --xhub
	ridxC = Array{Cint, 1}(ridx)
	cidxC = Array{Cint, 1}(cidx)
	# m and n are not really needed? --xhub
	mat = ccall((:empmat_triplet, "libjamsd"), Ptr{jamsd_sp_matrix}, (Cuint, Cuint, Cuint, Ptr{Cint}, Ptr{Cint}, Ref{Cdouble}),
							0, 0, length(vals), ridxC, cidxC, vals)
	return mat
end

function jamsd_mat_free(mat)
	ccall((:empmat_free, "libjamsd"), Void, (Ptr{jamsd_sp_matrix},), mat)
end

function jamsd_set_objeqn(ctx::Ptr{context}, idx)
	res = ccall((:model_setobjequ, "libjamsd"), Cint, (Ptr{context}, Cint), ctx, idx)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_set_rhs(ctx::Ptr{context}, idx, val)
	res = ccall((:ctx_setrhs, "libjamsd"), Cint, (Ptr{context}, Cint, Cdouble), ctx, idx, val)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_set_equtype(ctx::Ptr{context}, idx, rel)
	res = ccall((:ctx_setequtype, "libjamsd"), Cint, (Ptr{context}, Cint, Cuint), ctx, idx, rel)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_set_vartype(ctx::Ptr{context}, idx, typ)
	res = ccall((:ctx_setvartype, "libjamsd"), Cint, (Ptr{context}, Cint, Cuint), ctx, idx, typ)
	res != 0 && error("return code $res from JAMSD")
end

function jamsd_get_treedata(ctx, i::Int)
	tree = ccall((:myo_getequtree, "libjamsd"), Ptr{equtree}, (Ptr{context}, Cint), ctx, i)
	node = Ref{Ref{Ptr{equnode}}}(C_NULL)
	res = equtree_get_root_addr(tree, node)
	res != 0 && error("return code $res from JAMSD")
	return (tree, node)
end
